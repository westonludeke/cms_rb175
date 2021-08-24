ENV["RACK_ENV"] = "test"

require "fileutils"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = "")
    File.open(File.join(data_path, name), "w") do |file|
      file.write(content)
    end
  end

  def admin_session
    { "rack.session" => { username: "admin" } }
  end

  def session
    last_request.env["rack.session"]
  end

  def test_index
    create_document "about.md"
    create_document "changes.txt"

    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
  end

  def test_viewing_text_document
    create_document "history.txt", "Ruby 2.7 released."

    get "/history.txt"

    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "Ruby 2.7 released."
  end

  def test_viewing_markdown_document
    create_document "about.md", "# Ruby is..."

    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end

  def test_document_not_found
    get "/notafile.ext"

    assert_equal 302, last_response.status
    assert_equal "notafile.ext does not exist", session[:message]
  end

  def test_editing_document
    create_document "changes.txt"

    get "/changes.txt/edit", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<textarea"
    assert_includes last_response.body, %q(<button type="submit")
  end

  def test_editing_document_signed_out
    create_document "changes.txt"

    get "/changes.txt/edit"

    assert_equal 302, last_response.status
    assert_equal "Sorry, you must be logged in to do that!", session[:message]
  end

  def test_updating_document
    post "/changes.txt/edit", {content: "new content"}, admin_session

    assert_equal 302, last_response.status
    assert_equal "changes.txt has been edited", session[:message]

    get "/changes.txt"
    assert_equal 200, last_response.status
    assert_includes last_response.body, "new content"
  end

  def test_updating_document_signed_out
    post "/changes.txt/edit"
    assert_equal 302, last_response.status 
    assert_equal "Sorry, you must be logged in to do that!", session[:message]
  end

  def test_new_file_page
    get "/new", {}, admin_session

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_new_file_page_logged_out
    get "/new"
    assert_equal 302, last_response.status
    assert_equal "Sorry, you must be logged in to do that!", session[:message]
  end

  def test_creating_new_document
    post "/create", {new_file_name: "new_file.html"}, admin_session
    assert_equal 302, last_response.status 
    assert_equal "new_file.html has been created!", session[:message]

    get "/"
    assert_includes last_response.body, "new_file.html"
  end

  def test_creating_new_document_logged_out
    post "/create", {new_file_name: "new_file.css"}
    assert_equal 302, last_response.status
    assert_equal "Sorry, you must be logged in to do that!", session[:message]
  end

  def test_create_new_document_without_filename
    post "/create", {new_file_name: ""}, admin_session
    assert_equal 422, last_response.status
    assert_includes last_response.body, "The file name cannot be blank"
  end

  def test_deleting_document
    create_document("delete_me.txt")

    post "/delete_me.txt/delete", {}, admin_session
    assert_equal 302, last_response.status
    assert_equal "delete_me.txt has been deleted", session[:message]

    get "/"
    refute_includes last_response.body, %q(href="/test.txt")
  end

  def test_deleting_document_logged_out
    create_document("delete_me.txt")

    post "/delete_me.txt/delete"
    assert_equal 302, last_response.status
    assert_equal "Sorry, you must be logged in to do that!", session[:message]
  end

  def test_login_form
    get "/users/login"

    assert_equal 200, last_response.status
    assert_includes last_response.body, "<input"
    assert_includes last_response.body, %q(<input type="submit")
  end

  def test_loggin_in
    post "/users/login", username: "admin", password: "secret"
    assert_equal 302, last_response.status
    assert_equal "Welcome!", session[:message]
    assert_equal "admin", session[:username]

    get last_response["Location"]
    assert_includes last_response.body, "Signed in as: admin"
  end

  def test_signin_with_bad_credentials
    post "/users/login", username: "guest", password: "bad_password"
    assert_equal 422, last_response.status
    assert_includes last_response.body, "Invalid user credentials"
  end

  def test_logging_out
    get "/", {}, {"rack.session" => { username: "admin"} }
    assert_includes last_response.body, "Signed in as: admin"

    post "/users/logout"
    assert_equal "You are now logged out!", session[:message]

    get last_response["Location"]
    assert_nil session[:username]
    assert_includes last_response.body, "Log In"
  end
end









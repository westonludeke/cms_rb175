ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"
    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about.md"
    assert_includes last_response.body, "changes.txt"
    assert_includes last_response.body, "history.txt"
  end

  def test_history
    get "/history.txt"
    assert_equal 200, last_response.status
    assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "2019 - Ruby 2.7 released."
  end

  def test_document_not_found
    get "/notafile.ext" # attempt to access a nonexistent file

    assert_equal 302, last_response.status # assert the user was redirected

    get last_response["Location"] # request the page that the user was redidrected to

    assert_equal 200, last_response.status
    assert_includes last_response.body, "notafile.ext does not exist"


    get "/" # reload the page
    refute_includes last_response.body, "notafile.ext does not exist" # assert that the message has been removed
  end

  def test_viewing_markdown_document
    get "/about.md"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "<h1>Ruby is...</h1>"
  end
end

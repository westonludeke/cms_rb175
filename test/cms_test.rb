ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"

require_relative "../cms"

class CmsTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get "/"

    assert_equal 200, last_response.status
    assert_equal "text/html;charset=utf-8", last_response["Content-Type"]
    assert_includes last_response.body, "about"
    assert_includes last_response.body, "changes"
    assert_includes last_response.body, "history"
  end

  def test_viewing_text_document
    get "/#{@page_id}"

    assert_equal 200, last_response.status
    # assert_equal "text/plain", last_response["Content-Type"]
    assert_includes last_response.body, "a"
  end
end

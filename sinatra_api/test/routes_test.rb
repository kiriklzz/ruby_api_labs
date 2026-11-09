ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require_relative '../my_sinatra'

class RoutesTest < Minitest::Test
  include Rack::Test::Methods

  def app
    MyAppModule::App
  end

  def test_named_route_and_redirect
    get '/hello/Peter'
    assert_includes last_response.body, 'Peter'
    get '/redirect'
    assert last_response.redirect?
    follow_redirect!
    assert_includes last_response.body, 'World'
  end

  def test_splat_and_optional_format
    get '/say/hello/to/world'
    assert_equal ['hello', 'world'], JSON.parse(last_response.body)
    get '/download/path/to/file.xml'
    assert_equal ['path/to/file', 'xml'], JSON.parse(last_response.body)
    get '/jobs.json'
    assert_equal 'Да, работает этот маршрут!', last_response.body
    get '/meta/hello/world'
    assert_equal 'Hello, world!', last_response.body
  end

  def test_namespace_and_fallback
    ['/', '/friends', '/api/v1/friends'].each do |path|
      get path
      assert_equal 200, last_response.status
    end
  end
end

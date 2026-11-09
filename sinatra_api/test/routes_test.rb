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
    get '/hello_block/Peter'
    assert_equal 'Hello Peter!', last_response.body
    get '/hello/%3Cscript%3E'
    assert_equal 'text/plain', last_response.media_type
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
    get '/meta/hello/12345/world'
    assert_equal 'Hello, 12345!', last_response.body
    get '/jobs.xml'
    assert_equal 'Да, работает этот маршрут!', last_response.body
    get '/players/football'
    assert_equal 'football', last_response.body
    get '/players/performances/2016'
    assert_equal({ 'splat' => ['performances'], 'year' => '2016' }, JSON.parse(last_response.body))
  end

  def test_namespace_and_fallback
    ['/', '/friends', '/api/v1/friends'].each do |path|
      get path
      assert_equal 200, last_response.status
    end
  end
end

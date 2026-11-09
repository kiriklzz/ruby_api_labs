require 'sinatra/base'
require 'sinatra/namespace'
require 'json'

module MyAppModule
  class App < Sinatra::Base
    register Sinatra::Namespace

    before { content_type :text }

    get('/') { 'Hello My Sinatra - Easy and Wide world!' }
    get('/hello/:name') { "Sinatra приветствует тебя, #{params[:name]}!" }
    get('/hello_block/:name') { |name| "Hello #{name}!" }
    get('/players/:sport_id') { params[:sport_id] }
    get('/players/*/:year') { { splat: params[:splat], year: params[:year] }.to_json }
    get('/redirect') { redirect to('/hello/World') }
    get('/say/*/to/*') { params[:splat].to_json }
    get('/download/*.*') { params[:splat].to_json }
    get('/jobs.?:format?') { 'Да, работает этот маршрут!' }
    get(%r{/meta/hello/(\w+)(?:/.*)?}) { |name| "Hello, #{name}!" }

    namespace '/api/v1' do
      get('/*') { "I don't know what is the #{params[:splat]}. It's what you typed." }
    end

    get('/*') { "I don't know what is the #{params[:splat]}. It's what you typed." }

    run! if app_file == $PROGRAM_NAME
  end
end

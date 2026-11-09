require 'sinatra'
require 'sinatra/namespace'

before { content_type :text }
get('/') { 'Hello My Sinatra - Easy and Wide world!' }
get('/hello/:name') { "Sinatra приветствует тебя, #{params[:name]}!" }

namespace '/api/v1' do
  get('/*') { "I don't know what is the #{params[:splat]}. It's what you typed." }
end

get('/*') { "I don't know what is the #{params[:splat]}. It's what you typed." }

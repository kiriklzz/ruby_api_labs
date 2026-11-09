require 'sinatra'
require 'sinatra/namespace'
require 'json'
require_relative 'config/database'

%w[models helpers routes].each do |dir|
  Dir[File.join(__dir__, dir, '*.rb')].sort.each { |file| require file }
end

get('/') { 'Hi! I am api_sinatra_postgres!' }

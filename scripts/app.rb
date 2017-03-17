require 'rubygems'
require 'sinatra'
require 'sinatra/json'
#require 'json'

get '/' do
  "Hello and Goodbye"
end

get '/hi' do
  #str = "Hello World! :)"
  data={:content=>[1,2,3]}
  json data
end

get '/bye:n/:m' do
  "Goodbye World! :( [#{params[:n]}] [#{params[:m]}]"
end

require 'rubygems'
require 'sinatra'
require "sinatra/basic_auth"
require 'open-uri'
require 'haml'
require './proxy_jc'
require 'json'
#require 'newrelic_rpm'

#set :public_folder, '/data/scripts/R/public'

authorize "Public" do |username, password|
  username == 'g' && password == 'g'
end

authorize "Admin" do |username, password|
  username == 'a' && password == 'a'
end

protect "Public" do
  get '/pub' do
    '...pub'
  end
end

protect "Admin" do
  get '/' do
    body  `ruby parse.rb`
  end
end

protect "Admin" do
  get '/user/:id' do
    uid = params[:id]
      #return open("http://172.16.0.2:4567/view/#{id}").read
      #get_log1(uid)
      body `ruby -W0 log.rb #{uid}`
  end
end

protect "Admin" do
  get '/v2/user/:id' do
    uid = params[:id]
      #return open("http://172.16.0.2:4567/view/#{id}").read
      #get_log1(uid)
      body `ruby -W0 log2.rb #{uid}`
  end
end

protect "Admin" do
  get '/user/:id/date/:date' do
    uid = params[:id]
    date =  params[:date]

    body `ruby -W0 log.rb #{uid} #{date}`
  end
end

protect "Admin" do
  get '/v2/user/:id/date/:date' do
    uid = params[:id]
    date =  params[:date]

    body `ruby -W0 log2.rb #{uid} #{date}`
  end
end

protect "Admin" do
  get '/proxy' do
    h = get_data
    body print_html(h)
  end
end

protect "Admin" do
  get '/1.pdf' do
    send_file '/data/scripts/R/public/1.pdf',:disposition=>"inline"
  end
end

get '/test/:id' do
    file = params[:id]
    `ruby inc.rb #{file} #{request.ip}`
    redirect "http://download.ip.com/android/#{file}.apk"
end

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
  username == 'ad' && password == 'pwd'
end

authorize "Imp" do |username, password|
  username == 'ad' && password == 'pwd'
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
  get '/v2/user/:id/page/:n' do
    uid = params[:id]
    n = params[:n]
      #return open("http://172.16.0.2:4567/view/#{id}").read
      #get_log1(uid)        
      body `ruby -W0 log2.rb #{uid} 0  #{n}`
  end         
end    

protect "Admin" do
  get '/v2/list/:from-:to' do
    from = params[:from]
    to = params[:to]

    body `ruby -W0 from_to.rb #{from} #{to} 1`
  end
end

protect "Admin" do  
  get '/v2/list/:from-:to/page/:n' do
    from = params[:from]
    to = params[:to]
    n = params[:n]

    body `ruby -W0 from_to.rb #{from} #{to} #{n}`
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
  get '/cn/user/:id/date/:date' do
    uid = params[:id]
    date =  params[:date]

    body `ruby -W0 creport/log2.rb #{uid} #{date}`
  end
end

protect "Admin" do
  get '/cn/user/:id' do
    uid = params[:id]
      #return open("http://172.16.0.2:4567/view/#{id}").read
      #get_log1(uid)
      body `ruby -W0 creport/log2.rb #{uid}`
  end
end

protect "Admin" do
  get '/cn/user/:id/page/:n' do
    uid = params[:id]
    n = params[:n]
      #return open("http://172.16.0.2:4567/view/#{id}").read
      #get_log1(uid)
      body `ruby -W0 creport/log2.rb #{uid} 0  #{n}`
  end
end


protect "Admin" do
  get '/kpi' do
    body `ruby kpi.rb 30`
  end
end

protect "Admin" do
  get '/kpi/:n' do
    n = params[:n].to_i
    n = 30 if n == 0  
    body `ruby kpi.rb #{n}`  
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

def get_platform(str)
  platform = 'pc'
  if str =~ /iphone/i or str =~ /ipad/i or str =~ /ipod/i or str =~ /ios/i
    platform = 'appstore'
  end

  platform = 'android' if str =~ /android/i
  platform
end

get '/test/:id' do
    file = params[:id]
    `ruby inc.rb #{file} #{request.ip} #{get_platform(request.user_agent)}`
    redirect "http://download.com/android/#{file}.apk"
end


get '/test2/:file/:plat/:ip' do
    file = params[:file]
    plat = params[:plat]
    ip = params[:ip]
                     
    `ruby inc.rb #{file} #{ip} #{plat}`
    #redirect "http://download.com/android/#{file}.apk"
    "ok" 
end

protect "Admin" do
  get '/count' do
    body `ruby -W0 count.rb`
  end
end


get '/foo' do
  str = request.inspect
  str += '[['
  str += request['HTTP_X_FORWARDED_FOR'] if request['HTTP_X_FORWARDED_FOR']
  str += 'for' if request.forwarded?
  str += ']]'
  if(!request['HTTP_X_FORWARDED_FOR'] && !request['HTTP_VIA'] && !request['HTTP_PROXY_CONNECTION']) 
    str += 'proxylevel_elite'
  elsif (!request['HTTP_X_FORWARDED_FOR']) 
    str +=  'proxylevel_anonymous'
  else 
   str +=  'proxylevel_transparent'
  end
  body str
end


get '/2.pdf' do              
    send_file '/data/scripts/report/2.pdf',:disposition=>"inline"
end             

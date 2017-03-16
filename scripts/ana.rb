require 'rubygems'
require 'sinatra'
require 'pp'
require 'open-uri'
require 'json'
require 'redis'
require '/data/scripts/common_cfg'


get '/view/:id' do
  id = params[:id]
  str = `cat /data/ProgramFiles/nginx/logs/access.log |grep v2 |  grep "userid=#{id}&"`.split(/\n/)
  str = str.reverse  #.join("<br />")

  arr = []

  str.each do |i|

    ip = i.split(/-/)[0].strip

    m = $r.get(ip)
    unless  m
      h =  JSON.parse(open("http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=#{ip}").read)
      arr << "#{h['province']}-#{h['city']}"
      $r.set(ip,"#{h['province']}-#{h['city']}")
    else
      arr << m
    end
    i = i.gsub(/GET \/car\/data\/list!getList\.do\?/,"").gsub(/HTTP\/1\.1/,"").gsub(/android.*?async-http\)/,'').gsub(/-/,'').gsub(/"/,'')

    arr << i
    arr << "<br/>"
  end

  pp arr


  body arr
end


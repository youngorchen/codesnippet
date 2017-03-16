require 'rubygems'
require 'active_record'
require 'yaml'
require 'pp'
require 'mysql2'
require 'json'
require 'redis'
require 'date'
require '/data/scripts/common_cfg'

ip = "106.49.82.79"

  str = ""
  pp ip 

  ip = ip.strip

  return ip if ip =~ /^172\./

  m = $r.get(ip)
  unless  m
    begin
      h =  JSON.parse(`curl "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=#{ip}"`)
      str =  "#{h['province']}-#{h['city']}"
      #$r.set(ip,"#{h['province']}-#{h['city']}")
#      str = `curl -s "http://wap.ip138.com/ip_search.asp?ip=#{ip}" | grep "查询结果："`
pp str      
if str =~ /<b>查询结果：(.*)<\/b>/
        str = $1
pp str
        $r.set(ip,str)
      end
    rescue Exception => e
        puts e.backtrace
puts ".."
      str = ip
    end
  else
    str =  m
  end
   pp str
  str





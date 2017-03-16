# -*- coding: UTF-8 -*-

require 'rubygems'
require 'pp'
require 'json'
require 'redis'
require 'open-uri'
require '/data/scripts/common_cfg'

def check_proxy(ip_port,n)

=begin 
  url =  "http://61.4.82.128/checkproxy/checker.php"
  
  str = `curl -S -m 10 -x #{ip_port} #{url}`

  puts str

  ret = 3

  if str =~ /elite/
  	ret = 0 
  	$r.incrby "elite_ips_#{n}",1
    puts "ee"*80
  end
  if str =~ /anonymous/
  	ret = 1 
  	$r.incrby "anonymous_ips_#{n}",1
    puts "aaa"*80
  end
  if str =~ /transparent/
  	ret = 2 
  	$r.incrby "normal_ips_#{n}",1
    puts "nnn"*80
  end
  
=end

 ret = 2

  if ret != 3
  	puts "!"*200 
  	@ip_array << ip_port 
  	$r.incrby "proxy_web#{n}_ok",1

  	puts "@@@@@@@@@@@@@@@@@@@"
	puts ip_port

	  $r.rpush "ips", ip_port
	  (1..8).each do |i|
	  	$r.rpush "ips#{i}", ip_port
	  end
  end
  puts "ret=",ret
end

host=ARGV[0]
len = ARGV[1]


pp ARGV

@ip_array=[]


def get_ip(len)
 return []
  ips = JSON.parse(`curl "http://ip1/"`)["ips"]
  
  puts "get_ip"
  pp ips if $DEBUG

  arr = []

  ips.each do |i|
	ip_str = "#{i['address']}:#{i['port']}"
	arr << ip_str
	$r.sadd "ips_back", ip_str
  end
  
  $r.incrby "proxy_web1_fetch",len

  pp arr
  arr
end


get_ip1(len).each do |ip|
  #get_time ip, host,2
  begin
    check_proxy(ip,2)
  rescue
    #next
  end
end



pp @ip_array


puts @ip_array.length





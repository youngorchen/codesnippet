require 'rubygems'
require 'json'
require 'pp'
require './calc'
require 'redis'
require '/data/scripts/common_cfg'
 
 n = $r.llen("ips")

arr=[]

  start =( n*rand).to_i
pp start
pp  arr <<  $r.lrange("ips",start,start+2)

a =[]
arr=[]
pp arr << $r.lpop("ips")
pp arr << $r.lpop("ips")

a << arr
pp a

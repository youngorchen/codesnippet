require 'json'
require 'pp'
require 'redis'
require './builder/builder'
#require '/data/scripts/common_cfg'

$r = Redis.new :host => "vpn.cyhz.com", :port => 6379

def get_proxy
  #proxy = `curl 'http://www.56pu.com/fetch?orderId=739764093472990&quantity=1&line=all&region=&regionEx=&beginWith=&ports=&speed=&anonymity=&scheme='` #'190.203.97.250:9064'

  proxy = `curl -s http://172.16.0.3:3333/ips#{rand(8).to_i}/1`
  #proxy = $r.lpop "ips"
  return $1 if proxy =~ /(\d+\.\d+.\d+.\d+:\d+)/m

  return '114.46.226.198:8088'
end

def push_queue_with(return_code,url,proxy,json_string=nil,error_string=nil)
  #builde val json...
  obj = {}
  obj['code'] = return_code
  obj['msg'] = error_string
  obj['url'] = url
  obj['proxy'] = proxy

  obj['data']=JSON.parse(json_string)

  puts obj.to_json

  $r.rpush(QUEUE_NAME + "_RETURN",obj.to_json)
end


QUEUE_NAME = "CRAWL_TASK_QUEUE_TEST"

proxy = '' #get_proxy
MAX_RETRY = 5
n = 0

t = nil
#t = $r.lpop (QUEUE_NAME)

loop do
 
  # t = 'http://heb.273.cn/car/14237280.html'
  # t = 'http://th.273.cn/car/13332953.html'  wrong

  until t
    sleep 1 
    t = $r.lpop (QUEUE_NAME)
    n = 0
  end
  #return unless t # t is json format
  t1 = JSON.parse(t)

  #cmd = "ruby builder.rb car_detail.yaml #{t} #{proxy} "
  
  ARGV[0] = './builder/tmp/'+ t1['template']  #'car_detail.yaml'
  ARGV[1] = t1['url']
  ARGV[2] = proxy
  
  pp "argv:"
  pp ARGV
  code = run_main

  #not right...change proxy
  if code.to_i != 0
  	puts "=========================the [#{n}]th retry =================================>change proxy!!! #{$?} !!"

    #if n == 0
    #  proxy = '' #try no proxy first
    #else
  	# proxy = get_proxy
    #end
    proxy = get_proxy
    
  	n += 1
  
  else
      #right then next one... 
      #t = $r.lpop (QUEUE_NAME) 
      #n = 0
      if File.exist?("#{$root_file}.json4")
        #error exist?
        if File.exist?("#{$root_file}.error")
          push_queue_with(1,t1['url'],proxy,IO.read("#{$root_file}.json4"),IO.read("#{$root_file}.error"))
          `rm -rf #{$root_file}.json4`
          `rm -rf #{$root_file}.error`
        else
          push_queue_with(0,t1['url'],proxy,IO.read("#{$root_file}.json4"))
          `rm -rf #{$root_file}.json4`
        end
      else
        puts "strange! no json4 but return 0!****************************"
      end
      t = nil
      next
  end

  #extra max times then next one
  if n > MAX_RETRY
     #t = $r.lpop (QUEUE_NAME) 
     #n = 0
     push_queue_with(404,t1['url'],proxy)
     t = nil
     next 
  end

  sleep 1  
end




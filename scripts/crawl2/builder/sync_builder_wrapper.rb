require 'json'
require 'pp'
#require 'redis'
require './builder'
require 'sinatra'
require 'cgi'


def get_proxy
  proxy = `curl -s http://ip:3333/ips#{rand(8).to_i}/1`
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

  pp json_string

  obj['data']=JSON.parse(json_string)

  puts obj.to_json

  #$r.rpush(QUEUE_NAME + "_RETURN",obj.to_json)
  obj.to_json
end

MAX_RETRY = 5

def url_json(arg)

  #$r = Redis.new :host => "ip", :port => 6379
  #QUEUE_NAME = "CRAWL_TASK_QUEUE"

  proxy = '' #get_proxy
  
  n = 0

  #t = nil
  t = {}

  #cmd = "ruby builder.rb car_detail.yaml #{t} #{proxy} "

  #t = $r.lpop (QUEUE_NAME)
  t['template'] = arg[0]
  t['url'] = arg[1]

  ret_str = ''

  loop do
    until t
      #sleep 1 
      #t = $r.lpop (QUEUE_NAME)
      n = 0
      exit
    end
    #return unless t # t is json format
    #t1 = JSON.parse(t)

    #cmd = "ruby builder.rb car_detail.yaml #{t} #{proxy} "
    
    #ARGV[0] = t1['template']  #'car_detail.yaml'
    #ARGV[1] = t1['url']

    ARGV[0] = arg['template']
    ARGV[1] = arg['url']
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
            ret_str = push_queue_with(1,t['url'],proxy,IO.read("#{$root_file}.json4"),IO.read("#{$root_file}.error"))
            `rm -rf #{$root_file}.json4`
            `rm -rf #{$root_file}.error`
            return ret_str
          else
            ret_str = push_queue_with(0,t['url'],proxy,IO.read("#{$root_file}.json4"))
            `rm -rf #{$root_file}.json4`
            return ret_str
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
       ret_str = push_queue_with(404,t['url'],proxy)
       return ret_str
       #t = nil
       #next 
    end

    sleep 1  
  end
end

post '/url2json' do
    arg = {}
    arg['url'] = CGI.escape(params[:url])
    arg['template'] = params[:template]

    pp arg
    pp '=========================='*80
    
    unless arg['template'].index('/')
      arg['template'] = '/data/scripts/crawl/builder/tmp/' + arg['template']
    end

    pp arg
    body url_json(arg)
end

#STDERR.puts "=="*80
#arg = ARGV
#STDERR.puts url_json(arg)


# -*- coding: UTF-8 -*-

require 'json'
require 'pp'
require 'redis'
#require './builder'
require 'cgi'
require '/data/scripts/common_cfg'

def invalid_txt?(fn)
  txts=%w(
    a b c )

  str = IO.read(fn)

  txts.each do |t|
    if fn.include?(t) and str.include?(t)
      puts "..."*500
      return false 
    end
  end

  return true
=begin
	txts=%w(百度手机助手 bv cc )

	str = IO.read(fn)

	txts.each do |t|
		if str.include?(t)
			puts t + "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
			return true 
		end
	end

	unless str.include?('title')
		puts "no title!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		return true 
	end

	if fn.include?('taoche') and not str.include?('bitauto_logo')
		puts "yiche special!^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
		return true 
	end
  return false
=end

	
end

def get_proxy
  
  proxy = `curl -s http://ip:3333/ips#{rand(8).to_i}/1`
  #proxy = $r.lpop "ips"
  return $1 if proxy =~ /(\d+\.\d+.\d+.\d+:\d+)/m

  return '114.46.226.198:8088'
end

def get_web_file(url,cfg)
  #fn = url.gsub(/\//,'_').gsub(/:|\./,'_').scan(/http(.*)/)[0][0]
  #fn = fn_convt(url)
  #fn = fn.gsub(/\?/,'_')  #bug here!
  #puts fn
  fn = CGI.escape(url)

  #curl -x 116.53.8.105:2386 --max-time 5 --retry 10 --retry-delay 1 -C - -o a.html http://www.baidu.com

  # --max-time 5 --retry 10 --retry-delay 1
  #str = 'curl  -L '
  str = 'curl  -s '
  #str = 'curl -A "Mozilla/5.0 (Windows NT 6.3; WOW64; Trident/7.0; Touch; .NET4.0E; .NET4.0C; Tablet PC 2.0; .NET CLR 3.5.30729; .NET CLR 2.0.50727; .NET CLR 3.0.30729; InfoPath.3; LCJB; rv:11.0) like Gecko" -s '

  pp cfg

  #exit

  if cfg['proxy']  #proxy
    if cfg['proxy'] =~ /ARGV/
      proxy = eval cfg['proxy']
    else
      proxy = cfg['proxy']
    end
    str += " -x #{proxy} " if proxy.strip.length > 10 
  end

  
  str += " --max-time #{cfg['max-time']} " if cfg['max-time']  #max-time
  str += " --retry #{cfg['retry']} " if cfg['retry']  #retry
  str += " --retry-delay #{cfg['retry-delay']} " if cfg['retry-delay']  #retry-delay
  str += " -C - " if cfg['duan-dian'] == 'true'
  str += " -o #{fn} #{url}" 
  puts str
  puts `#{str}`

  puts code = $?
  return '11' if $?.exitstatus != 0  #timeout, change proxy?
  
  if not File.exist?(fn) 
    puts "EEEEEE"*12
    return '11'
  end

  if (size = File.size(fn))< cfg['filesize']
    puts "SSSSSS"*12
    return '11'
  end

  if invalid_txt?(fn)
	 puts "IIIIII"*12
     return '11'
  end  	

  puts "==========================================>file size: #{size}!####################################################################################"

  fn
end




QUEUE_NAME = "zhi_detail_ba"
QUEUE_NAME = "zhg_detail_#{ARGV[0]}" if ARGV[0]

q_pre = "SCT_CRAWL_"

proxy = get_proxy  #''
MAX_RETRY = 5
n = 0

t = nil

cfg = {}
cfg['proxy'] = proxy #''
#cfg['retry'] = 2
cfg['max-time'] = 15
#cfg['retry-delay'] = 0

cfg['filesize'] = 5000
url = ''
fn = ''
#cfg['retry-delay'] =


#t = $r.lpop (QUEUE_NAME)

loop do
 begin
  # t = 'http://heb.273.cn/car/14237280.html'
  # t = 'http://th.273.cn/car/13332953.html'  wrong

  until t
    sleep 1 if $r.llen(QUEUE_NAME) < 5
    t = $r.lpop (QUEUE_NAME)
    n = 0
  end
  #return unless t # t is json format
  puts "*"*120
  puts Time.now
  puts "new data:-----" + "-" * 100 + ">>>"
  pp t
  puts "*"*120
  
  t = t.to_s
  t1 = JSON.parse(t)
  #t1 = {}
  #%w(cid city price publishTime site siteValue source state type url count).each do |sd|
  #  puts "----"*80
  #  pp sd
  #  pp t[sd]
  #  pp eval(t[sd])
  #  t1[sd] = t[sd]
  #end

  #cmd = "ruby builder.rb car_detail.yaml #{t} #{proxy} "
  
  #ARGV[0] = t1['template']  #'car_detail.yaml'
  #ARGV[1] = t1['url']
  #ARGV[2] = proxy
  
  #pp ARGV
  url = t1["url"]
  
  pp "="*80
  pp url
  pp proxy
  pp "="*80
  

  code = get_web_file(url,cfg)

  #not right...change proxy
  if code.to_i == 11
  	puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXthe [#{n}]th retry XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX>change proxy!!! #{$?} !!"

    
    proxy = get_proxy

    cfg['proxy'] = proxy
    
  	n += 1
  
  else
      #right then next one... 
      #t = $r.lpop (QUEUE_NAME) 
      #n = 0
      j = {}
      key = q_pre + QUEUE_NAME + '_html_' + code
      j['url'] = url
      j['key'] = key
      j['site'] = t1["site"]

      %w(cid city price publishTime siteValue source state type count).each do |inx|
        j[inx] = t1[inx]
      end

      $r.lpush(q_pre + QUEUE_NAME + '_html',j.to_json)
      pp code
      pp 
      site_v = t1['siteValue'].to_i
      
      #che168/sohu
      if site_v == 7 or site_v == 9
        #$r.lpush(q_pre + QUEUE_NAME + '_html',j.to_json) 
        puts "===>gb2312 encoding"*8  
        $r.set(key, open(code,'r:gb2312').read.encode('utf-8'))
      elsif site_v == 5  #51auto
    #  puts "===>gbk encoding"*8  
        #$r.lpush(q_pre + QUEUE_NAME + '_html_51',j.to_json)
        $r.set(key, open(code,'r:gbk').read.encode('utf-8'))
      else
        #$r.lpush(q_pre + QUEUE_NAME + '_html',j.to_json)
        $r.set(key, IO.read(code))
      end

      `rm -rf #{code}`
      t = nil
      #exit
      #sleep 10
      next
  end

  #extra max times then next one
  if n > MAX_RETRY
     #t = $r.lpop (QUEUE_NAME) 
     #n = 0
     
     t = nil
     #`rm -rf #{code}`  #new add: clean
     next 
  end
 rescue
  puts $@
  t = nil # throw
  puts "@@"*80
  #exit
  sleep 2
  next
 end
  sleep ARGV[2].to_i if ARGV[2]
end





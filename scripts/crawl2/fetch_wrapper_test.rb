require 'json'
require 'pp'
require 'redis'
#require './builder'
require 'cgi'
#require '/data/scripts/common_cfg'

$r = Redis.new :host => "ip", :port => 6379

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
  str = 'curl -s '

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
  str += " -o #{fn} \"#{url}\"" 
  puts str
  puts `#{str}`

  puts code = $?
#puts "...."*80
puts $?.exitstatus
#puts "...."*80

  return '11' if $?.exitstatus.to_i != 0  #timeout, change proxy?

#puts "XXXXXXXXXXXXX"
    
  fn
end



QUEUE_NAME = "ip"
q_pre = "RET_"

proxy = '' #get_proxy
MAX_RETRY = 5
n = 0

t = nil

cfg = {}
cfg['proxy'] = ''
#cfg['retry'] = 
cfg['max-time'] = 5
url = ''
fn = ''
#cfg['retry-delay'] =


#t = $r.lpop (QUEUE_NAME)
json = false

loop do
  
  until t
    sleep 1 
    t = $r.lpop (QUEUE_NAME)
    n = 0
    json = false
  end
  #return unless t # t is json format

 unless json
  #puts "---"*80
  pp t
  #puts "___"*80
  
  t = JSON.parse(t.to_s)
  json = true 
 end

  pp t
puts "XXX"*80

  #cmd = "ruby builder.rb car_detail.yaml #{t} #{proxy} "
  
  #ARGV[0] = t1['template']  #'car_detail.yaml'
  #ARGV[1] = t1['url']
  #ARGV[2] = proxy
  
  #pp ARGV
  url = t["url"]
  code = get_web_file(url,cfg)

  #not right...change proxy
  if code.to_i == 11
  	puts "=========================the [#{n}]th retry =================================>change proxy!!! #{$?} !!"

    
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
      j['site'] = t["site"]

      %w(cid city price publishTime siteValue source state type).each do |inx|
        j[inx] = t[inx]
      end

      $r.lpush(q_pre + QUEUE_NAME + '_html',j.to_json)
      pp fn
      $r.set(key, ss = IO.read(code))

      puts "\t\t#####################{ss}################"

      `rm -rf #{code}`
      t = nil
      #exit
      next
  end

  #extra max times then next one
  if n > MAX_RETRY
     #t = $r.lpop (QUEUE_NAME) 
     #n = 0
     
     t = nil
     next 
  end

  sleep 1  
end





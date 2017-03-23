# -*- coding: UTF-8 -*-

# test: ruby  -W0 weixin.rb test

#require 'watir'
#require 'watir-webdriver'
require 'rubygems'

require 'pp'
require 'date'
require 'redis'

#$M_DEBUG = true
require './db'
#require './filter'
require '/data/scripts/common_cfg'

# read.rb filter.rb map.rb send.rb

$redis = $r 

def replace(name)
  puts name
  %w(手机用户 bxuser 用户 user 百姓).each do |item|
    return '未留名' if name.index(item)
  end

  return '未留名' if name.length > 4

  name
end

def t_proc(d)
  #d=Time.at(d.to_i+8*3600) #bug
  d_min=d.min
  d_min = "0#{d_min}" if d.min < 10

  "#{d.month}月#{d.day}日  #{d.hour}:#{d_min}"
end

def my_print(key,str,extra=nil,sep=nil)
  return '' unless str
  str = str.strip.gsub(/\s+/,' ')
  return '' if str.length < 1

  if extra and extra.strip.length > 1
    #puts "=="*80
    #pp str

    #pp sep
    #return "#{key}#{str} （#{extra}）\n"  unless sep
    str.gsub!(/（该信息由用户发自手机）/,'')
    return "#{key}#{str}#{sep}\n"  if extra == '++'
    return "#{key}#{str}#{sep}#{extra}\n"  if extra != '++'
  end

  return "#{key}#{str}\n"
end

#main ...

def car_send(cid,len)
  cars = nil
  if $M_DEBUG
    cars = SendQueue.where(["client_id = ? and sent_by_weixin is  NULL or sent_by_weixin < '2014-06-08'",cid]).order('created_at DESC').limit(len)
  else
    cars = SendQueue.where(["client_id = ? and sent_by_weixin is  NULL",cid]).order('created_at DESC').limit(len)
  end
  
  client = Client.find_by_cid(cid)
  pp client
  return unless client
  
  pp cars.length
  rid = client.chatroom

  if client.enable == 0
        #filter的意思
		SendQueue.where(["client_id = ? and sent_by_weixin is  NULL",cid]).order('created_at DESC').each do |ttt|
			ttt.update_attributes(:sent_by_weixin=>DateTime.parse('2007-01-01 00:00:00')) 
		end
        return
  end
	  
	  
  puts "click #{rid} ===>"
  $browser.div(:id,'conv_newsapp').click
  $browser.div(:id,rid).click

  puts "..."
  
  cars.each do |i|
    begin
      #:name,:area,:phone,:meno,:area_supplement,:message,:from,:created_at
      #pp j.class
      pp i
      cid = i.client_id
      j = CarSource.find(i.car_id)
      next unless j
      pp j
      name = j.name2 || ""
      title = j.title
      desc = j.desc
      price = j.price.to_f
      if price > 0
        price = "#{price}万"
      else
        price = ''
      end
      licenceDate = j.licenceDate
      mileage = j.mileage
      if not mileage or mileage.strip == ''
          mileage = ''
      else
          mileage = "#{mileage}万公里"
      end

      puts licenceDate,mileage

      if eval("c_#{cid}_filter(j)")
        #filter的意思
        i.update_attributes(:sent_by_weixin=>DateTime.parse('2007-01-01 00:00:00')) 
        next
      end

	  
      name = replace(name)

      str = my_print('客户：',name)
      str += my_print('电话：', j.phone)
      k = ''
      k = j.city if j.city

      str += my_print('时间：',t_proc(j.created_at))
      str += my_print('地区：',k)

      str += my_print("\n售车信息：\n",title)
      str += my_print("上牌日期：",licenceDate)
      str += my_print("行驶里程：","#{mileage}")

      str += my_print("意向售价：",price.to_s)
      str += my_print(' （',desc,'++','）')

      puts str

      unless $M_DEBUG
        #client = Client.find_by_cid(cid)
        #next unless client
        #pp client
    
        #send_chat(client.chatroom,str)
        direct_send(str)
        #sleep 5
        i.update_attributes(:sent_by_weixin=>Time.now)
        $redis.sadd("wx_mobiles_#{cid}",j.phone)
      else
        puts '===='*80 
        STDIN.gets
      end
    #rescue
    #  next
    end
  end
  
  puts Time.now
end

#type_2

def car_send_2(cid,len)
  cars = nil
  if $M_DEBUG
    cars = SendQueue.where(["client_id = ? and sent_by_weixin is  NULL or sent_by_weixin < '2014-06-08'",cid]).order('created_at DESC').limit(len)
  else
    cars = SendQueue.where(["client_id = ? and sent_by_weixin is  NULL",cid]).order('created_at DESC').limit(len)
  end
  
  puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  pp cars.length
  puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
  
  
  client = Client.find_by_cid(cid)
  pp client
  return unless client
  
  if client.enable == 0
        #filter的意思
		SendQueue.where(["client_id = ? and sent_by_weixin is  NULL",cid]).order('created_at DESC').each do |ttt|
			ttt.update_attributes(:sent_by_weixin=>DateTime.parse('2007-01-01 00:00:00')) 
		end
        return
  end
	  

  cars.each do |i|
    begin
      #:name,:area,:phone,:meno,:area_supplement,:message,:from,:created_at
      #pp j.class
      pp i
	  
	  
      cid = i.client_id
      j = CarSource.find(i.car_id)
      next unless j
	  
  
      name = j.name2 || ""
      name = replace(name)

	  name = "" if name == '未留名'
      
	  
	  
      if eval("c_#{cid}_filter(j)")
        #filter的意思
		puts ".."	
        i.update_attributes(:sent_by_weixin=>DateTime.parse('2007-01-01 00:00:00')) 
        next
      end
	  
	  puts name,j.brand,j.seies,j.phone,j.webUrl

      unless $M_DEBUG
		require 'uri'
		final_url = URI::escape(j.webUrl)
		
	cmd="curl -s -d \"name=#{name}&mobile=#{j.phone}&brand=#{j.brand}&family=#{j.seies}&area=#{j.city}&source=ip\" -X POST http://www.ttpai.cn/control/TTPData"
		puts "..."*80
		puts "=====================> "+cmd
		
		puts `#{cmd}`
        i.update_attributes(:sent_by_weixin=>Time.now)
        $redis.sadd("wx_mobiles_#{cid}",j.phone)
      else
        puts '===='*80 
        STDIN.gets
      end
    #rescue
    #  next
    end
  end
  
  puts Time.now
end


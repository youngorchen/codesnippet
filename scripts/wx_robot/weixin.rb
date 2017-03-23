# -*- coding: UTF-8 -*-

# test: ruby  -W0 weixin.rb test

#require 'watir'
#require 'watir-webdriver'
require 'rubygems'
require 'mysql2'

require 'active_record'
require 'pp'
require 'date'
require 'redis'
require '/data/scripts/common_cfg'

@redis = $r

pp ARGV
$M_DEBUG = true if ARGV[0] == 'test'
browser = nil

def send_chat(rid,str)
  browser.div(:id,rid).click
  browser.text_field(:class, "chatInput lightBorder").set(str)
  browser.link(:class,"chatSend").click
end

unless $M_DEBUG
  require 'watir-classic'  
  #browser = Watir::Browser.attach :url, 'https://wx.qq.com/' 
  #browser = Watir::Browser.attach :url, 'https://wx2.qq.com/' unless browser
  begin
    browser = Watir::Browser.attach :title, 'Web WeChat' #unless browser
  rescue
    browser = Watir::Browser.new :ie
    browser.goto('https://wx.qq.com/?&lang=en')
    puts "按任何键继续 如果已经登录了。。。"
    STDIN.gets
  end
  # browser = Watir::Browser.attach :title, '微信网页版' #unless browser

  puts browser.url
  puts browser.title

  browser.bring_to_front
end

def connect_db   #Method is to connect DB
  unless $M_DEBUG
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => 'ip',
      :username => 'ip',
      :password => 'H',
      :database => 'zh',
    :port => 3306)

    ActiveRecord::Base.default_timezone = "Beijing"
    #ActiveRecord::Base.pluralize_table_names = false
  else
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => '6',
      :username => 'ip',
      :password => 'H',
      :database => 'zh',
    :port => 8004)

    ActiveRecord::Base.default_timezone = "Beijing"
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
end

connect_db

class LostCar < ActiveRecord::Base
end

class User < ActiveRecord::Base
end

def filter(car,user)
  msg = car.message || ""
  desc = user.desc || ""
  tel = car.tel

  if msg.index('背户') 
    puts "message 里面有背户"
    puts msg
    puts "XX"*200
    return true
  end

  if desc.index('背户') 
    puts "desc 里面有背户"
    puts desc
    puts "XX"*200
    return true
  end

  puts "-- #{@redis.sismember('wx_mobiles',tel)} --"

  if @redis.sismember('wx_mobiles',tel) 
    puts "已经发过了！"
    puts tel
    puts "XX"*200
    return true 
  end

  @redis.sadd('wx_mobiles',tel)

  return false
end

def t_proc(d)
  d=Time.at(d.to_i+8*3600) #bug
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

while true
  cars = nil
  if $M_DEBUG
    cars = LostCar.where(["buy_or_sell=? and (sent_by_weixin is  NULL or sent_by_weixin < '2000-01-01' )",'sell']).order('created_at DESC')
  else
    cars = LostCar.where(["buy_or_sell=? and (sent_by_weixin is NULL and created_at > '2014-06-08')",'sell']).order('created_at DESC')
  end

  cars.each do |i|
    begin
      pp i
      #:name,:area,:tel,:meno,:area_supplement,:message,:from,:created_at
      j = User.where(:tel=>i.tel).limit(1)[0]
      pp j
      #pp j.class
      name = ''
      title = ''
      desc = ''
      price = ''
      shangpai = ''
      miles = ''
      if j
        name = j.user_name
        title = j.title
        desc = j.desc
        price = j.price.to_f
        if price > 0
          price = "#{price}万"
        else
          price = ''
        end
        shangpai = j.listen_date
        miles = j.mileage
        if not miles or miles.strip == ''
            miles = ''
        else
            miles = "#{miles}万公里"
        end
      end
      puts shangpai,miles

      if filter(i,j)
        #filter的意思
        i.update_attributes(:sent_by_weixin=>DateTime.parse('1970-01-01 00:00:00'))
        next
      end

      str = my_print('客户：',name)
      str += my_print('电话：', i.tel)
      k = ''
      k = i.area if i.area

      str += my_print('时间：',t_proc(i.created_at))
      str += my_print('地区：','北京'+k,i.area_supplement,sep='-')

      str += my_print("\n售车信息：\n",title)
      str += my_print("上牌日期：",shangpai)
      str += my_print("行驶里程：","#{miles}")

      str += my_print("意向售价：",price.to_s)
      str += my_print(' （',desc,'++','）')

      str += my_print("\n最新留言：\n",i.message)


      puts str

      unless $M_DEBUG
        #browser.text_field(:class, "chatInput lightBorder").set(str)
        #browser.send_keys "\r"
        #browser.link(:class,"chatSend").click
        send_chat("conv_3727107300chatroom",str)
        #sleep 5
        i.update_attributes(:sent_by_weixin=>Time.now)
      else
        puts '===='*80 
        STDIN.gets
      end
    #rescue
    #  next
    end
  end
  #sleep 10
  browser.div(:id,"conv_newsapp").click
  puts Time.now
end

unless $M_DEBUG    
  browser.close
end


#20.times do |i|
#    browser.text_field(:class, "chatInput lightBorder").set("hello 中文 #{Time.now} ")
#    browser.send_keys "\r"
#browser.link(:class,"chatSend").click
#    sleep 5
#end


=begin
<div id="chat_editor" class="chatOperator lightBorder" ctrl="1">



    <div class="inputArea">

        <div class="attach"></div>

        <textarea id="textInput" class="chatInput lightBorder" type="text" style=""></textarea>

        <a class="chatSend" click="sendMsg@.inputArea" href="javascript:;"></a>


#news
conv_newsapp

#mail
conv_exmail_tool
#chatroom
conv_3727107300chatroom

def send_chat(rid,str)
  browser.div(:id,rid).click
  browser.text_field(:class, "chatInput lightBorder").set(str)
  browser.link(:class,"chatSend").click
end

send_chat("conv_3727107300chatroom",str)

browser.div(:id,"conv_newsapp").click

browser.div(:id,"conv_3727107300chatroom").click

browser.text_field(:class, "chatInput lightBorder").set(str)
browser.link(:class,"chatSend").click

=end



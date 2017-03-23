# -*- coding: UTF-8 -*-

# test: ruby  -W0 weixin.rb test

require 'pp'
pp ARGV
$M_DEBUG = true if ARGV[0] == 'test'
$browser = nil

def send_chat(rid,str)
  #$browser.bring_to_front
  puts "_"*80
  puts "click #{rid} ===>"
  $browser.div(:id,rid).click
  #sleep 1
  puts "set text..."
  $browser.text_field(:class, "chatInput lightBorder").set(str)
  puts "click sending"
  
  $browser.link(:class,"chatSend").click
  puts "_"*80
end

def direct_send(str)
  puts "_"*80
  puts "set text..."
  $browser.text_field(:class, "chatInput lightBorder").set(str)
  puts "click sending"
  
  $browser.link(:class,"chatSend").click
  puts "_"*80
end

unless $M_DEBUG
  require 'watir-classic'  
  #$browser = Watir::$browser.attach :url, 'https://wx.qq.com/' 
  #$browser = Watir::$browser.attach :url, 'https://wx2.qq.com/' unless $browser
  begin
    $browser = Watir::Browser.attach :title, 'Web WeChat' #unless $browser
  rescue
    $browser = Watir::Browser.new :ie
    $browser.goto('https://wx.qq.com/?&lang=en')
    puts "按任何键继续 如果已经登录了。。。"
    STDIN.gets
  end
  # $browser = Watir::$browser.attach :title, '微信网页版' #unless $browser

  puts $browser.url
  puts $browser.title

  $browser.bring_to_front
end

eval(IO.read("filter.rb"))

eval(IO.read("send.rb"))

$clients=%w(5)

while true
  begin
    t = DateTime.parse(Time.now.to_s)
    puts t
	
    if t.hour >= 8 and t.hour <= 23
      $clients.each do |c|
        car_send(c,10)
        puts Time.now
      end
	  
    else
      sleep 60
      puts Time.now
      next
    end
  rescue
  #  next
	puts "?????"*8000
	
     next 
  end
end

unless $M_DEBUG    
  $browser.close
end


#20.times do |i|
#    $browser.text_field(:class, "chatInput lightBorder").set("hello 中文 #{Time.now} ")
#    $browser.send_keys "\r"
#$browser.link(:class,"chatSend").click
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
  $browser.div(:id,rid).click
  $browser.text_field(:class, "chatInput lightBorder").set(str)
  $browser.link(:class,"chatSend").click
end

send_chat("conv_3727107300chatroom",str)

$browser.div(:id,"conv_newsapp").click

$browser.div(:id,"conv_3727107300chatroom").click

$browser.text_field(:class, "chatInput lightBorder").set(str)
$browser.link(:class,"chatSend").click

=end


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


eval(IO.read("filter.rb"))

eval(IO.read("send.rb"))

$clients_type_2=%w(6)

while true
  begin
    t = DateTime.parse(Time.now.to_s)
    puts t
	
    #if t.hour >= 8 and t.hour <= 23
	  $clients_type_2.each do |c|
             car_send_2(c,10)
             puts Time.now
          end
	  sleep 60
    #else
    #  sleep 60
    #  puts Time.now
    #  next
    #end
  #rescue
   # puts "?????"*8000
    #next
  end
end


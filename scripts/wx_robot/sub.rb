# -*- coding: UTF-8 -*-

require 'rubygems'
require 'stomp'
require 'pp'
require 'date'
require 'json'
require './db'
require './sub_filter'


$arr =CarSource.column_names - ["id","created_at","updated_at","name2"]
$city=%w(北京 哈尔滨 上海 深圳 无锡 郑州)
$clients=%w(3 4 5 6)

def mreplace(name)
  return '' unless name
  t = name.gsub(/\xC2\xA0/,'').gsub(/随时联系我/,'').gsub(/个人/,'').strip
  pp t
  return '未留名' if t.length > 4 or t =~ /^[a-z|A-Z]/ or t =~ /用户/
  return t
end

#city里面的个人
def filter(msg)
  return false if  msg['type_t'].to_i != 1 
  $city.each do |c|
    return true if msg['city'] == c # and msg['siteName'] != 'che168'
  end
  return false
end

def insert_table(msg)
  return unless filter(msg)

  pp msg
  puts "XX"*80
  i = CarSource.find_by_phone_and_title_and_name(msg["phone"],msg["title"],msg["name"]) || CarSource.new
    
  $arr.each do |col|
    eval "i.#{col}=msg[\"#{col}\"]"
  end

  i.name2 = mreplace(msg['name'])
  puts "#{i.name} ====> #{i.name2}"
  i.save

  $clients.each do |c|
    SendQueue.create :client_id => c,:car_id => i.id if eval("sub_#{c}_pass?(msg)")
  end 
end

$client_id = "rubyclient3"
$subscription_name = "ruby3"
$topic_name = "sendTopic"


stomp_params = {
  :hosts => [
    { :host => "ip", :port => 61613},
  ],
  :connect_headers => {'client-id' => $client_id},
}


client = Stomp::Client.new stomp_params

client.subscribe "/topic/#{$topic_name}", { "ack" => "client", "activemq.subscriptionName" => $subscription_name} do |msg|

=begin
  puts "--------------body----------------"
  puts msg.body
  puts "--------------headers----------------"
  puts msg.headers
  puts "-----end-----"
=end
  insert_table(JSON.parse(msg.body))

  client.acknowledge msg
  #STDIN.gets

end

client.join


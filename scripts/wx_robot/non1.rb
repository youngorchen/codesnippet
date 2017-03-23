# -*- coding: UTF-8 -*-

require 'rubygems'
require 'stomp'
require 'pp'
require 'date'
require 'json'
require './db'
require './sub_filter'



$client_id = "rubyclient3"
$subscription_name = "ruby3"

#$client_id = "rubyclient1"
#$subscription_name = "ruby1"
$topic_name = "sendTopic"


stomp_params = {
  :hosts => [
    { :host => "ip", :port => 61613},
  ],
  :connect_headers => {'client-id' => $client_id},
}


client = Stomp::Client.new stomp_params

client.subscribe "/topic/#{$topic_name}", { "ack" => "client", "activemq.subscriptionName" => $subscription_name} do |msg|

 begin
#=begin
  puts "--------------body----------------"
  puts msg.body
  puts "--------------headers----------------"
  puts msg.headers
  puts "-----end-----"
  #sleep 1  
#=end
  client.acknowledge msg
  #STDIN.gets
 rescue
  next
 end
  
end

client.join


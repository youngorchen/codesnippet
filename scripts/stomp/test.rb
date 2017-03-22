require 'onstomp'

# A simple message producer
client = OnStomp.connect('stomp://admin:admin@ip')
client.send('/queue/shop_add', 'hello world')
client.disconnect

# A simple message consumer
client = OnStomp::Client.new('stomp://admin:amin@172.16.0.3:61613')
client.connect
client.subscribe('/queue/shop_add', :ack => 'client') do |m|
  client.ack m
  puts "Got and ACK'd a message: #{m.body}"
end

while true
  # Keep the subscription running until the sun burns out
end

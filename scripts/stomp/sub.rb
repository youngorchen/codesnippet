require 'onstomp'


# A simple message consumer
client = OnStomp::Client.new('stomp://admin:amin@ip:61613')
client.connect
client.subscribe('/queue//queue/bang_update', :ack => 'client') do |m|
  client.ack m
  puts "Got and ACK'd a message: #{m.body}"
end

while true
  # Keep the subscription running until the sun burns out
end

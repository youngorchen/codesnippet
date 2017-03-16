require 'pp'

pp ARGV

t1 = Time.now
ARGV[1].to_i.times do |i|
	IO.read(ARGV[0])
end

puts (Time.now-t1)/ARGV[1].to_i

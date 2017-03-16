require 'pp'

 str =  `/opt/apache-activemq-5.9.0/bin/activemq-admin query  -QQueue=* --view DequeueCount,EnqueueCount,ConsumerCount,QueueSize,destinationName`

#pp str

 str=~/Connecting to pid: \d+\s*(.*)/m

arr = []
prop=%w(
	destinationName
	ConsumerCount
	QueueSize
	EnqueueCount
	DequeueCount
)

 $1.split(/\n\n/).each do |line|
	h = {}
	line.split(/\n/).each do |k|
		prop.each do |item|
			h["#{item}"] = $1 if k =~ /#{item}\s*=(.*)/
		end
	end
	arr.push h
 end

puts '<html><head><meta http-equiv="refresh" content="5" /></head><body><table border="1" width="100%">'
#str += "<tr>><th>destinationName</th><th>ConsumerCount</th><th>EnqueueCount</th><th>DequeueCount</th><th>QueueSize</th></tr>"

str = "<tr>"
  prop.each do |k|
    str +="<th>#{k}</th>"
  end
str += "</tr>"

file = File.open("data", "r")

arr.sort!{|x,y|  x["destinationName"]<=>y["destinationName"]}.each do |t|
	line = file.gets 
	line =~ /\s*(\d+),\s*(\d+)/
	s,z =$1.to_i,$2.to_i
#pp s,z
	str += "<tr>"
	prop.each do |k|
		v = t["#{k}"]
		v = v.to_i - s if k == "EnqueueCount"
		v = v.to_i - z if k == "DequeueCount"
		str += "<td>#{v}</td>"
	end
	str += "</tr>"
end

#file.close

if $DEBUG
puts "***"*800
file = File.open("data", "w+")

#File.open("data", "w+") { |f|
 arr.each do |t|
#  pp t
	file.puts "#{t['EnqueueCount'].to_i},#{t['DequeueCount'].to_i}\n"
 end
 file.close
#}
end
 

puts str
puts "</table></body></html>"



require 'rubygems'
require 'pp'
require './main'
require 'redis'
require '/data/scripts/common_cfg'

def estimate(es,total)
  #pp es
  t = Time.now
  n = t-Time.local(t.year,t.mon,t.day)
  es[" zoff_add"] = 0

  %w(w).each do |i|
    d = es[" result_detail_#{i}"].to_i
    a = es[" zo_#{i}_add"].to_i
    off = es[" zoff_#{i}_add"].to_i

    puts "#{i} percentage: #{((a+off)*100.0/d).to_i}%"
    puts "total detail: #{d} (estimate #{(d/n*3600*24).to_i}) | "
    puts "add: #{a} (estimate #{(a/n*3600*24).to_i})"
    puts "off: #{off} (estimate #{(off/n*3600*24).to_i})"
    
    
    puts "<br/>" 
  end
  puts "total: #{total} (estimate #{(total/n*3600*24).to_i})"
end

def change_value(arr)
  arr.each do |h|
    %w(g).each do |i|
      if h['destinationName'] == " detail_#{i}"
        h["QueueSize"] = $r.llen("zht_detail_#{i}") 
      end
      
      if h['destinationName'] == " detail_#{i}_img"
        h["QueueSize"] = $r.llen("zht_#{i}_img").to_i 
        h["EnqueueCount"] = $r.get("zht_#{i}_img.EnqueueCount").to_i
        h['DequeueCount'] = h["EnqueueCount"] - h["QueueSize"]
        h['ConsumerCount'] = 4*5 
      end
    end
  end
  arr
#  pp arr
end

def get_alias(name)
  return "" unless name
  case name.strip

  when /detail_(.*)_img/
    "#{$1}/21"

  when /zapp_(.*)_add/
    "#{$1}/4"

  when /zo_(.*)_add/
    "#{$1}/5"
  when /zo_(.*)_update/
    "#{$1}/71"

  when /zoff_(.*)/
    "#{$1}/zb"

  when /update_(.*)/
    "#{$1}/6"
  when /zapp_(.*)_update/
    "#{$1}/7"
 

  when /^detail_(.*)/
    "#{$1}/2"
  when /filter_(.*)/
    "#{$1}/1"
  when /result_detail_(.*)/
    "#{$1}/3" 
  when /result_shop_(.*)/
    "#{$1}/9"
  when /shop_(.*)/
    "#{$1}/8"

  else
    name
  end
end

prop=%w(
  destinationName
  ConsumerCount
  QueueSize
  EnqueueCount
  DequeueCount
)

str = `export JAVA_HOME=/data/ProgramFiles/jdk && /data/ProgramFiles/activemq/bin/activemq-admin query  -QQueue=* --view DequeueCount,EnqueueCount,ConsumerCount,QueueSize,destinationName`

pp str 
#exit



str=~/rmi:\/\/localhost:\d+\/jmxrmi(.*)/m

pp str
#exit

#exit unless $1 #need debug here if mq is dead...

arr = []

pp $1
exit

$1.split(/\n\n/).each do |line|
  h = {}
  line.split(/\n/).each do |k|
    prop.each do |item|
      h["#{item}"] = $1 if k =~ /#{item}\s*=(.*)/
    end    
  end
  #map alias
  h['alias'] = get_alias(h['destinationName'])
  arr.push h
end

#pp arr
arr = change_value(arr)
#pp arr

puts '<html><head><meta http-equiv="refresh" content="10" /></head><body>'

z_add = 0
output = 0
t23_lv1tolv2 = 0

arr.each do |i|
#	pp i
	z_add += i["EnqueueCount"].to_i if i['destinationName'] =~ /^detail.*_add/
	output += i["EnqueueCount"].to_i if i['destinationName']  =~ /zo_.*_add/
	t23_lv1tolv2 += i["EnqueueCount"].to_i if i['destinationName']  =~ /23_lv1tolv2/
end

t23_lv1tolv2 = 1 if t23_lv1tolv2 < 1
z_add = 1 if z_add < 1
output = 1 if output < 1

t1 = format("%0.2f",z_add*100.0/t23_lv1tolv2)
t2 = format("%0.2f",output*100.0/t23_lv1tolv2)
t3 = format("%0.2f",output*100.0/z_add)

#puts "采集=#{t23_lv1tolv2} 增加=#{z_add} 有效=#{output} 增加占比= #{t1}% 出金= #{t2}% 有效率= #{t3}% <br/> <br/>"

puts '<table border="1" width="100%">'
#str += "<tr bgcolor=\"#eeffee\"><th>destinationName</th><th>ConsumerCount</th><th>EnqueueCount</th><th>DequeueCount</th><th>QueueSize</th></tr>"

str = "<tr bgcolor=\"#cceecc\">"
prop.each do |k|
  str +="<th>#{k}</th>"
end
str += "</tr>"

file = File.open("data", "r")

total = 0

es = {}

arr.sort! { |x, y| x["alias"]<=>y["alias"] }.each do |t|
  line = file.gets
  line =~ /\s*(\d+),\s*(\d+)/
  s, z =$1.to_i, $2.to_i
#pp s,z
#pp t.to_s
  if t["destinationName"].index("filter")
	str += '<tr bgcolor="#ccccff">' 
  elsif t["destinationName"] =~ /zo_.*_add/  
	str += '<tr bgcolor="#ffcccc">'
  elsif t["destinationName"] =~ /img/
  	str += '<tr style="color: red;">'
  else 
	str += '<tr>'
  end
  prop.each do |k|
    v = t["#{k}"]
    v = v.to_i - s if k == "EnqueueCount"
    v = v.to_i - z if k == "DequeueCount"
    str += "<td>#{v}</td>"
    total += v.to_i if  t["destinationName"] =~ /zo_.*_add/ and k == "DequeueCount"
    es["#{t['destinationName']}"] = v.to_i if  (t["destinationName"] =~ /zo_.*_add/ or t["destinationName"] =~ /result_detail/ or t["destinationName"] =~ /zoff_.*_add/) and k == "DequeueCount"
  end
  str += "</tr>"
end

#file.close

if $DEBUG
  puts "***"*80
  file = File.open("data", "w+")

  #File.open("data", "w+") { |f|
  arr.each do |t|
    #  pp t
    file.puts "#{t['EnqueueCount'].to_i},#{t['DequeueCount'].to_i}\n"
  end
  file.close
  #}
end

HOUR = 0

HOUR = 1 if ARGV[0]
#pp HOUR, ARGV[0]

update_history(arr) if HOUR == 1

puts str
puts "</table></body></html>"

estimate(es,total)


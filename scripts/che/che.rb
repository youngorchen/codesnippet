# -*- coding: UTF-8 -*-

require 'uri'
require 'pp'
require 'json'
require 'rubygems'
require 'mysql2'

require 'active_record'
require 'date'

def connect_db   #Method is to connect DB
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => 'ip',
   
      :username => 'c',
      :password => 'H',
      :database => 'wx',
    :port => 3306)

    ActiveRecord::Base.default_timezone = "Beijing"
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
end

connect_db

class Che < ActiveRecord::Base
	self.table_name = "hh"
end


@token = 'cc'
@n = ARGV[0] || 40
@n=@n.to_i

@delay=ARGV[1] || 10
@delay = @delay.to_i


def write_table(msg)
	#puts "writing...."
	#puts msg
	#exit

	return if msg["resultId"].to_i != 0

	msgs = msg["data"]

	$arr =Che.column_names - ["id","created_at","updated_at"]

    t = DateTime.parse(Time.now.to_s)
=begin
	if t.hour < 3
        	@start_date = DateTime.new(t.year,t.mon,t.day-1,0,0,0)
	else
		@start_date = DateTime.new(t.year,t.mon,t.day,0,0,0)
	end
        @start_date = DateTime.new(t.year,t.mon,t.day,t.hour-1,t.min,t.sec)
=end
	puts @delay
	t3 = @start_date  - @delay/(24.0*60) # ten mins
	puts "##"*80
	puts t3

	
	msgs.each do |msg|
	  begin
		#i = Che.find_by_cid(msg["ID"]) || Che.new
		# 已经抓完了 说明
		#exit if DateTime.parse(msg["date"]) < DateTime.new(@start_date.year,@start_date.mon,@start_date.day,@start_date.hour,@start_date.min - 5,@start_date.sec)
		x = DateTime.parse(msg["date"])

		#pp x
		#STDIN.gets

		exit if x <=  t3 # ten mins

		i = Che.find_by_date_and_cid(x,msg["ID"]) 

		#puts "-"*120
		next if i

		puts "N"*120
		i = Che.new

		$arr.each do |col|
			#pp col
			#pp msg[col]
			eval "i.#{col}=msg[\"#{col}\"]" if col != "cid"
			eval "i.#{col}=msg[\"ID\"]" if col == "cid"
			eval "i.date=x" if col == "date"
		end

		i.save
		pp i
		#pp msg
		print "."
		#exit
	  #rescue
	  #	print i
	  #	next
	  end
	end
	puts Time.now
end

puts "***"*80

d = Che.select(:date).order("date desc").limit(1)[0]
puts d.date
@start_date = DateTime.parse(d.date.to_s)


str = "..."

c = URI::escape str

puts c
require 'json'

ipp = JSON.parse(`curl http://ip/ips2/1`)['ips'][0][0] + " -m 60 "


ret =  "curl  -d \"#{c}\" http://search"


puts ret
ret = `#{ret}`
puts ret
#puts ".........................."

j = JSON.parse(ret)
puts j["data"].length
exit if j["data"].length == 0
write_table(j)


while j["data"].length != 0
  begin
  	puts "@"*120
	puts j["data"].length

	puts j["data"][-1]
	d = DateTime.parse(j["data"][-1]["date"])
	puts d
	time = sprintf("%4d-%02d-%02d+%02d:%02d:%02d",d.year,d.month,d.day,d.hour,d.min,d.sec)
	pp time + '^^^^'
	#STDIN.gets
	#sleep 5
	#time = sprintf("%4d-%02d-%02d+%02d%3A%02d%3A%02d",d.year,d.month,d.day,d.hour,d.min,d.sec)

	str = "pd"

	c = URI::escape str

	ret =  "curl  -s -d \"#{c}\" http://rch"
	
	puts "-"*120
	puts ret
	puts "-"*120

	ret = `#{ret}`
	#puts ret
	#STDIN.gets
	#sleep 5
	j = JSON.parse(ret)
	puts j["data"][-1]
	puts d1 = DateTime.parse(j["data"][-1]["date"])
	exit if d1 == d
	#puts j
	write_table(j)
	#STDIN.gets # if $DEBUG
	#sleep rand(1000)
  #rescue
  #	next
  end
end






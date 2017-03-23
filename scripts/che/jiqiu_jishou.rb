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
    :port => 3306
)

    ActiveRecord::Base.default_timezone = "Beijing"
    #ActiveRecord::Base.logger = Logger.new(STDOUT)
end

connect_db

class JiQiuJiShou < ActiveRecord::Base
	self.table_name = "jiqiujishou"
end



@token = 'h'
@n = ARGV[0] || 40
@n=@n.to_i

@delay=ARGV[1] || 10
@delay = @delay.to_i

@type = ARGV[2] || 0

def write_table(msg)
	return if msg["resultId"].to_i != 0

	msgs = msg["data"]

	$arr =JiQiuJiShou.column_names - ["id","created_at","updated_at"]

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
		#i = JiQiuJiShou.find_by_cid(msg["ID"]) || JiQiuJiShou.new
		# 已经抓完了 说明
		#exit if DateTime.parse(msg["date"]) < DateTime.new(@start_date.year,@start_date.mon,@start_date.day,@start_date.hour,@start_date.min - 5,@start_date.sec)

		if DateTime.parse(msg["date_create"]) <=  t3 # ten mins
			puts "?"*80
			puts DateTime.parse(msg["date_create"])
			puts t3
			exit
		end

		i = JiQiuJiShou.find_by_cid(msg["id"]) 

		next if i

		i = JiQiuJiShou.new

		$arr.each do |col|
			eval "i.#{col}=msg[\"#{col}\"]" if col != "cid" and col != "mtype"
			eval "i.#{col}=msg[\"id\"]" if col == "cid"
			eval "i.#{col}=msg[\"type\"]" if col == "mtype"
		end

		i.save
		pp i
		print "."
	  #rescue
	  #	
	  #	next
	  end
	end
	puts Time.now
end

puts "***"*80

d = JiQiuJiShou.select(:date_create).order("date_create desc").limit(1)[0]
if d 
	puts d.date_create
	@start_date = DateTime.parse(d.date_create)
else
	@start_date = Time.now
end

str = "tokn=#{@token}&annoutype=#{@type}"

c = URI::escape str

puts c
ret =  `curl -d "#{c}" http://s `
#puts ret

j = JSON.parse(ret)
puts j["data"].length
exit if j["data"].length == 0
write_table(j)


while j["data"].length != 0
  begin
	puts j["data"].length

	puts j["data"][-1]
	d = DateTime.parse(j["data"][-1]["date_create"])
	time = sprintf("%4d-%02d-%02d+%02d:%02d:%02d",d.year,d.month,d.day,d.hour,d.min,d.sec)

	str = "tok=#{@token}&annoe_type=#{@type}&time=#{time}"

	c = URI::escape str

	puts c
	ret =  `curl -d "#{c}" http://c `
	#puts ret

	j = JSON.parse(ret)
	#puts j
	write_table(j)
	#STDIN.gets if $DEBUG
	#sleep rand(1000)
  rescue
  	next
  end
end

=begin

=end



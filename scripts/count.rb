require 'rubygems'
require 'pp'
require 'json'
require 'redis'
require 'active_record'
require 'yaml'
require 'mysql2'
require '/data/scripts/common_cfg'

def connect_db   #Method is to connect DB
        ActiveRecord::Base.establish_connection(
        :adapter  => 'mysql2',
        :host     => 'x.x.x.x',
#	:port => 3307,
        :username => 'user',
        :password => 'pwd',
        :database => 'jc')

        ActiveRecord::Base.default_timezone = "Beijing"
        #ActiveRecord::Base.pluralize_table_names = false
end

connect_db

class Download < ActiveRecord::Base
end

def get_ip(ip)
  require 'open-uri'
  open("http://ip:3333/ip/#{ip}").read
end


def update_db
	Download.create :ip=>ARGV[1],:name=>ARGV[0],:location=>get_ip(ARGV[1])
end

def inc

	$r.incr "jc_#{ARGV[0]}_download_counter"
end

#inc

#update_db

#SELECT * from downloads where created_at > "2014-04-28 20:40" GROUP BY ip

#-- SELECT * from downloads where created_at > "2014-04-16 20:00" and channel like '%91%' GROUP BY ip 
#-- SELECT * from downloads where created_at > "2014-04-16 20:00" and channel like '%anzhi%' GROUP BY ip 
#-- SELECT * from downloads where created_at > "2014-04-16 20:00" and channel like '%appstore%' GROUP BY ip 
#TODO...
date = "2014-05-28 20:15"


str = "SELECT * from downloads where created_at > \"#{date}\" GROUP BY ip"
#puts str
total = Download.find_by_sql(str).length
total = 1 if total == 0

puts "total #{total} downloads/visits"
puts "<br/>"

str = "SELECT * from downloads where created_at > \"#{date}\"  and channel like '%91%' GROUP BY ip"
#puts str
c_91 = Download.find_by_sql(str).length
puts "download/visit from 91: #{c_91}"
puts "<br/>"

str = "SELECT * from downloads where created_at > \"#{date}\"  and channel like '%anzhi%' GROUP BY ip" 
#puts str
c_az = Download.find_by_sql(str).length
puts "download/visit from anzhi: #{c_az}"
puts "<br/>"

str = "SELECT * from downloads where created_at > \"#{date}\"  and channel like '%appstore%' GROUP BY ip" 
#puts str
c_app = Download.find_by_sql(str).length


puts "s.cyhz.com: #{total - c_91 - c_az} "
puts "<br/>"

puts "apple/total = #{c_app}/#{total} = #{c_app*100/total}%"
puts "<br/>"

class SctAppFtUserBrowseTrace < ActiveRecord::Base
  #table_name 'sct_app_ft_user_browse_trace'
end

SctAppFtUserBrowseTrace.establish_connection(
        :adapter  => 'mysql2',
        :host     => 'ip',
        :username => 'user',
        :password => 'pwd',
        :database => 'db')

SctAppFtUserBrowseTrace.table_name= 'table'

str = 'SELECT DISTINCT user_id  from trace'
c_users = SctAppFtUserBrowseTrace.find_by_sql(str).length - 4987
#TODO..
puts "added users #{c_users}"

puts "<br/>"

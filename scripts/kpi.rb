require 'rubygems'
require 'active_record'
require 'yaml'
require 'pp'
require 'mysql2'
require 'json'
require 'redis'
require 'date'
require 'open-uri'


@adapter= "mysql2"
@host= "ip"
@database= "db"
@username= "user"
@password= "pwd"


def connect_db
  ActiveRecord::Base.establish_connection(
    :adapter  => @adapter,
    :host     => @host,
    :username => @username,
    :password => @password,
  :database => @database)

  #  ActiveRecord::Base.default_timezone = "Beijing"
  ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base.send(:inheritance_column=, 'runtime_class')
  #ActiveRecord::Base.logger = Logger.new(STDOUT)
end

connect_db

class SctAppFtUserBrowseTrace < ActiveRecord::Base
end

class CarInfo < ActiveRecord::Base
end

class SctUserInfoT < ActiveRecord::Base
end

def get_ip(ip)
  open("http://ip:3333/ip/#{ip}").read
end



def kpi(num=60)
  puts '<table border="1" width="100%">'
  puts '<tr>'

  d = Date.today - num

  (1..num).each do |i|
    puts "<th>#{(d+i).day}</th>"
  end

  puts '<th>sum</th></tr>'

  tmp = 0
  
  total_len = SctAppFtUserBrowseTrace.select(:user_id).uniq.length

  rr = SctAppFtUserBrowseTrace.select(:user_id).uniq
  
  tc = 0

  (1..num).each do |k|
    nn = 0
    rr.each do |i|
      begin
        t = SctAppFtUserBrowseTrace.where(["user_id=? and ctime >= ? and ctime < ?",i.user_id,d+k,d+k+1]).length
        
        tc += 1 if t > 0
        nn += 1 if t > 0 
      rescue Exception => e
        puts e.backtrace if $DEBUG
        next
      end
    end
    puts "<td>#{nn}</td>"
  end

  puts "<td>#{tc}</td></tr>"
  puts "</table>"

  print "<br/>人均使用天数T（总天数/用户数）= #{tc}/#{total_len} = "
  puts "#{printf("%0.2f",tc*1.0/total_len)}"

end


kpi(ARGV[0].to_i)

kpi(10) if $DEBUG


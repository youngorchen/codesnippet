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
#  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

connect_db

class UserOperationLog < ActiveRecord::Base
end

class CarInfo < ActiveRecord::Base
end

class UserInfoT < ActiveRecord::Base
end

def get_ip(ip)
  open("http://ip:3333/ip/#{ip}").read
end


def sep(uid,t,n=30)
  d = Date.today - n
  h = {}
  (1..n).each do |i|
    h["#{d + i}"] = 0
  end

  (1..n).each do |i|
    pp d+i if $DEBUG
    t.each do |tt|
      pp tt if $DEBUG
      h["#{d + i}"] += 1 if tt >= (d + i ) and tt < (d + i + 1)
    end
  end
  pp h if $DEBUG
  str = ""
  h.each do |k,v|
    str += "<td bgcolor=\"#44ffff\"><a href=\"./#{uid}/date/#{k}\">#{v}</a></td>" unless v.to_i == 0
    str += "<td><a href=\"./#{uid}/date/#{k}\">#{v}</a></td>" if v.to_i == 0
  end
  str
end

def get_all
  num = 30
  puts '<table border="1" width="100%">'
  puts '<tr><th>id</th><th>name</th><th>mobile</th><th>last login time</th><th>last login ip</th><th>总登陆次数</th>'

  d = Date.today - num

  (1..num).each do |i|
    puts "<th>#{(d+i).day}</th>"
  end

  puts '</tr>'

  tmp = 0
  rr = UserOperationLog.select(:userid).order(:userid).uniq
  rr.each do |i|
    #get_log1(i.userid)
    begin
      r = UserInfoT.find(i.userid)
      t = UserOperationLog.where(:userid=>i.userid).order("ctime desc")
      arr = []
      t.each do |tt|
        arr << tt.ctime
      end
      t1 = t[0]
      n = t.length

      puts "<tr>" if tmp % 2 == 0
      puts '<tr bgcolor="#ccccff">' if tmp % 2 == 1
      tmp +=1

      puts "<td><a href=\"http://jc.zhihuantong.com/user/#{i.userid}\">#{i.userid}</a></td><td>#{r.name}</td><td>#{r.pin}</td><td>#{t1.ctime}</td><td>#{get_ip(t1.ip)}</td><td>#{n}</td>#{sep(i.userid,arr,num)}</tr>"
    rescue Exception => e
      puts e.backtrace if $DEBUG
      next
    end
  end
  puts "</table>"
  puts "total: #{rr.length}"
end

def map(j)
	u=%w(个人/最新鲜 商家/最新鲜 个人/刚刷新 商家/刚刷新 其他/最新鲜 其他/刚刷新)
	str = '查看：'
	if j["carid"]
		#puts j['carid'].to_i
		begin
			car = CarInfo.find(j['carid'].to_i)
			str += "<a href=\"#{car.url}\">#{car.title}</a>" 
		rescue
			str += j["carid"]
		end
	end
	if j["requesttype"]
		i = j["requesttype"].to_i
		str += "#{u[i]} 第#{j['requestpage']}页" 
	end
	if j["phonenumber"]
		str += "电话号码 #{j['phonenumber']}" 
	end
	if j["myCar"]
		str += "我的收藏"
	end
	str
end

def filter_json(str)
	h = JSON.parse(str)
	h.delete("code")
    h.delete("userid")
    h
end

def get_log1(uid,date)
  if uid == 'all'
    get_all
    return
  end
  puts '<table border="1" width="100%">'
  puts '<tr><th>ip</th><th>操作</th><th>时间</th><th>参数</th></tr>'

  begin
  	tmp = 0
  	users = nil

    unless date
      users = UserOperationLog.where(:userid=>uid).order("ctime desc")
    else
      d = Date.parse(date)
      users = UserOperationLog.where("userid=:userid and ctime >= :d1 and ctime < :d2",{:userid=>uid,:d1=>d,:d2=>d+1 }).order("ctime desc")
	end
	users.each do |i|
	    i.params = filter_json(i.params)
	    puts "<tr>" if tmp % 2 == 0
	  	puts '<tr bgcolor="#ccccff">' if tmp % 2 == 1
	  	tmp +=1

	    puts "<td>#{get_ip(i.ip)}</td><td>#{i.uri.split('/')[-1].gsub(/\.do/,'')}</td><td>#{i.ctime}</td><td>#{map(i.params)}</td></tr>"
	end
  rescue Exception => e
    puts e.backtrace 
    puts "数据出现异常！"
  end
  puts "</table>"
end

#get_log1(5)

get_log1(ARGV[0],ARGV[1]) unless $DEBUG

puts get_ip("117.136.63.149") if $DEBUG




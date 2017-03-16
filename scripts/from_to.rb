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

# t 是访问的时间记录
# uid
# 今天开始的前一个月或者前N天

def sep_str(uid,h)
  str = ""
  h.each do |k,v|
  	v = 1 if v.to_i > 0
    str += "<td bgcolor=\"#44ffff\"><a href=\"/v2/user/#{uid}/date/#{k}\">#{v}</a></td>" unless v.to_i == 0
    str += "<td><a href=\"./#{uid}/date/#{k}\">#{v}</a></td>" if v.to_i == 0    
  end
  n = h.select{|k,v| v > 0}.length
  str += "<td>#{n}</td>"
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
  h
end

def print_sum(hh)
	puts ""
end

def get_log1(from,to,page=1)
  page = page.to_i
  page = 1 if page < 1
  per_page = 200

  num = 15
  puts '<table border="1" width="100%">'
  puts '<tr><th>id</th><th>name</th><th>mobile</th><th>last login time</th><th>last login ip</th><th>总登陆次数</th>'

  d = Date.today - num

  (1..num).each do |i|
    puts "<th>#{(d+i).day}</th>"
  end

  puts '<th>sum</th></tr>'

  tmp = 0
  #rr = SctAppFtUserBrowseTrace.select(:user_id).order(:user_id).uniq
  #sql = "SELECT DISTINCT user_id  from sct_app_ft_user_browse_trace ORDER BY user_id LIMIT #{limit} offset #{offset}"

  limit = per_page
  offset = per_page*(page-1)
  total_len = SctAppFtUserBrowseTrace.select(:user_id).where(["user_id >= ? and user_id <= ?",from,to]).uniq.length
  #puts total_len,from,to

  #exit

  rr = SctAppFtUserBrowseTrace.select(:user_id).where(["user_id >= ? and user_id <= ?",from,to]).uniq.limit(limit).offset(offset)

  hh = []

  rr.each do |i|
    #get_log1(i.user_id)
    begin
      r = SctUserInfoT.find(i.user_id)
      t = SctAppFtUserBrowseTrace.where(:user_id=>i.user_id).order("ctime desc")
      arr = []
      t.each do |tt|
        arr << tt.ctime
      end
      t1 = t[0]
      n = t.length

      puts "<tr>" if tmp % 2 == 0
      puts '<tr bgcolor="#ccccff">' if tmp % 2 == 1
      tmp +=1

      h = sep(i.user_id,arr,num)
      puts "<td><a href=\"http://jc.zhihuantong.com/v2/user/#{i.user_id}\">#{i.user_id}</a></td><td>#{r.name}</td><td>#{r.pin}</td><td>#{t1.ctime}</td><td>#{get_ip(t1.ip)}</td><td>#{n}</td>#{sep_str(i.user_id,h)}</tr>"

      hh << h 
    rescue Exception => e
      puts e.backtrace if $DEBUG
      next
    end
  end
  puts "<tr bgcolor=\"#ffff\"><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td><td>-</td>"

  d = Date.today - num
  tc = 0
  (1..num).each do |i|
  	count = 0
  	hh.each do |h|
  		count += 1 if h["#{d+i}"] > 0
  	end
    puts "<td>#{count}</td>"
    tc += count
  end

  puts "<td>#{tc}</td></tr>"

  puts "</table>"
  #puts "total: #{rr.length}"
  
  pages = (total_len/per_page).to_i if total_len % per_page == 0
  pages = (total_len/per_page).to_i + 1 unless total_len % per_page == 0

  (1..pages).each do |n| 
    print "<a href=\"/v2/list/#{from}-#{to}/page/#{n}\">#{n}</a> " 
  end 
  puts "<br/><b>total: [#{total_len}] users, [#{pages}]pages, per page: #{per_page}</b>"

  print "<br/>人均使用天数T（总天数/用户数）= "
  puts "#{printf("%0.2f",tc*1.0/rr.length)}"

end

def map(j)
  return j
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
	#h.delete("code")
  h.delete("user_id")
  h
end


##{from} #{to} #{n}

get_log1(ARGV[0].to_i,ARGV[1].to_i,ARGV[2].to_i)

get_log1(50000,60000,1) if $DEBUG



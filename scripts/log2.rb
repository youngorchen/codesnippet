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

def get_version(r)
  begin
   arr = []
   r.each do |i|
    arr << $1 if i.user_agent =~/souchetong-(.*)\|/
   end
   arr = arr.uniq.sort {|b,a| a.scan(/\d+/).join <=> b.scan(/\d+/).join }  
   
   if arr.length > 3
      "("+arr[0..2].join(",")+")" 
   else
      "("+arr.join(",")+")" 
   end
  #rescue
    
  end
  #""
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
    str += "<td bgcolor=\"#44ffff\"><a href=\"/v2/user/#{uid}/date/#{k}\">#{v}</a></td>" unless v.to_i == 0
    str += "<td><a href=\"./#{uid}/date/#{k}\">#{v}</a></td>" if v.to_i == 0    
  end
  str
end

def get_all(page=1)
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

  puts '<th>版本历史</th></tr>'

  tmp = 0
  #rr = SctAppFtUserBrowseTrace.select(:user_id).order(:user_id).uniq
  #sql = "SELECT DISTINCT user_id  from sct_app_ft_user_browse_trace ORDER BY user_id LIMIT #{limit} offset #{offset}"

  limit = per_page
  offset = per_page*(page-1)
  total_len = SctAppFtUserBrowseTrace.select(:user_id).uniq.length

  rr = SctAppFtUserBrowseTrace.select(:user_id).uniq.order(:user_id).limit(limit).offset(offset)


  rr.each do |i|
    #get_log1(i.user_id)
    begin
      next if i.user_id == 0
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

      #puts t1.user_agent
      #puts get_version(t1.user_agent)

      puts "<td><a href=\"http://jc.zhihuantong.com/v2/user/#{i.user_id}\">#{i.user_id}</a></td><td>#{r.name}</td><td>#{r.pin}</td><td>#{t1.ctime}</td><td>#{get_ip(t1.ip)}</td><td>#{n}</td>#{sep(i.user_id,arr,num)}<td>#{get_version(t)}</td></tr>"
    rescue # Exception => e
      #puts e.backtrace #if $DEBUG
      next
    end
  end
  puts "</table>"
  #puts "total: #{rr.length}"
  
  pages = (total_len/per_page).to_i if total_len % per_page == 0
  pages = (total_len/per_page).to_i + 1 unless total_len % per_page == 0

  (1..pages).each do |n| 
    print "<a href=\"/v2/user/all/page/#{n}\">#{n}</a> " 
  end 
  puts "<br/><b>total: [#{total_len}] users, [#{pages}]pages, per page: #{per_page}</b>"

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

def get_log1(uid,date,page=1)
  if uid == 'all'
    get_all(page)
    return
  end
  puts '<table border="1" width="100%">'
  puts '<tr><th>ip</th><th>操作</th><th>时间</th><th>参数</th></tr>'

  begin
  	tmp = 0
  	users = nil

    unless date
      users = SctAppFtUserBrowseTrace.where(:user_id=>uid).order("ctime desc")
    else
      d = Date.parse(date)
      users = SctAppFtUserBrowseTrace.where("user_id=:user_id and ctime >= :d1 and ctime < :d2",{:user_id=>uid,:d1=>d,:d2=>d+1 }).order("ctime desc")
	end
	users.each do |i|
	    i.params = filter_json(i.params)
	    puts "<tr>" if tmp % 2 == 0
	  	puts '<tr bgcolor="#ccccff">' if tmp % 2 == 1
	  	tmp +=1

	    puts "<td>#{get_ip(i.ip)}</td><td>#{i.uri}</td><td>#{i.ctime}</td><td>#{map(i.params)}</td></tr>"
	end
  rescue Exception => e
    puts e.backtrace 
    puts "数据出现异常！"
  end
  puts "</table>"
end

#get_log1(5)

get_log1(ARGV[0],ARGV[1],ARGV[2])

#puts get_ip("106.49.82.79") if $DEBUG
#get_version('android_4.4.2|souchetong-1.2_26|SM-N9006')





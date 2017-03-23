# -*- coding: UTF-8 -*-

require 'rubygems'
require 'mysql2'
require 'pp'
require 'iconv'

=begin
接口一：
上传用户的手机通讯录  post
http://ip:8000/api/input_mobile_list
参数：
1.	mobile  手机号
2.	list     通讯录，数组
测试页面：
http://ip:8000/api/mytest

ex: curl -d "mobile=13616644999&list[]=13611644999&list[]=13611644998" http://ip:8000/api/input_mobile_list


接口二：
获取指定手机号的一度好友 get
http://ip:8000/api/one_degree_friends?mobile=*******
参数：
1.	mobile  手机号
ex: curl http://ip:8000/api/one_degree_friends?mobile=13616644999


接口三：
获取指定手机号的二度好友 get
http://ip:8000/api/two_degree_friends?mobile=*******
参数：
1.	 mobile  手机号
ex: curl http://ip:8000/api/two_degree_friends?mobile=13616644999


接口四：
获取两个手机号的关系，若为二度好友返回共同好友 get
http://ip:8000/api/both_friends?mobile1=*******&mobile2=*******
参数：
1.	mobile1
2.	mobile2
返回结果
{:type => *, :common_friends => [手机号, 手机号]}
type可能有三种情况
0	非好友关系
1	一度好友
2	二度好友  此时会同时返回commin_friends
ex: curl http://ip:8000/api/both_friends?mobile1=13616644999&mobile2=13616644991

browser graph： http://ip:8001/browser/
=end

@URL="http://ip:8000"

def post_contact(mobile,list)
	str = "curl -d \"mobile=#{mobile}"
	
	list.each do |item|
		str += "&list[]=#{item}"
	end

	str += "\" #{@URL}/api/input_mobile_list"

	puts str

	puts `#{str}`
end

def get_contact(mobile)
	puts `#{@URL}/api/get_mobile_list?mobile=#{mobile}`
end

def get_1(mobile)
	puts `curl #{@URL}/api/one_degree_friends?mobile=#{mobile}`
end

def get_2(mobile)
	puts `curl #{@URL}/api/two_degree_friends?mobile=#{mobile}`
end

def get_relationship(m1,m2)
	puts `curl #{@URL}/api/both_friends?mobile1=#{m1}&mobile2=#{m2}`
end

post_contact '18616644999',%w(18616644998 18616644996 18616644995 18616644997)
get_contact '18616644999'

post_contact '18616644998',%w(18616644999 18616644996 18616644997)
get_contact '18616644998'

post_contact '18616644997',%w(18616644998 18616644996 18616644994 18616644993)
get_contact '18616644997'

post_contact '18616644996',%w(18616644998 18616644995 18616644997)
get_contact '18616644996'

post_contact '18616644994',%w(18616644996 18616644997)
get_contact '18616644994'

post_contact '18616644993',%w(18616644994)
get_contact '18616644993'


%w(18616644993 18616644994 18616644995 18616644996 18616644997 18616644998 18616644999).each do |m|
	get_1(m)
	get_2(m)
end	

%w(18616644993 18616644994 18616644995 18616644996 18616644997 18616644998 18616644999).each do |m1|
	%w(18616644993 18616644994 18616644995 18616644996 18616644997 18616644998 18616644999).each do |m2|
		get_relationship(m1,m2)
	end
end


require 'open-uri'
require 'nokogiri'
require 'pp'
require 'json'

#a=open("http://chain.273.cn/map/#shops_1","r:gbk").read
#a=open("team.html").read
url = ARGV[0]
a=open(url).read
#puts a

doc = Nokogiri::HTML(a)

data = {}

data[:url] = url
data[:mechant_name] = doc.css("div.name.clearfix h2")[0].content.strip
#mechant_slogan = doc.css("div.sign")[0].content.strip
data[:mechant_addr] = doc.css(".des")[0].content.scan(/门店地址：(.*) /)[0][0].strip

arr = []

data[:data] = arr

doc.css("div#list dl").each do |i|
        obj = {}
        obj[:img] = i.css("img").attr('src').content.strip
        obj[:name] = i.css("a")[1].content.strip
        tel = i.css("strong.hot")[0].content + i.css("strong.hot")[1].content
        obj[:tel] = tel.scan(/\d+/).join
        arr << obj
end

puts data.to_json


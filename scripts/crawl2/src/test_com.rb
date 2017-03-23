#require 'harmony'
require 'open-uri'
#require 'hpricot'
require 'nokogiri'

str = 'http://www.bmw-bps.com.cn/showroom/car_details.html?secondHandCarId=4e6eb91e-5db4-4eea-8d4a-3fa015b4f823'

#page = Harmony::Page.fetch(str)

page = open(str) #{|f| Hpricot(f) }

dom = Nokogiri::HTML(page)

puts dom

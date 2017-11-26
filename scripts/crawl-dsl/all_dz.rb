urls = [
'https://faw-vw.che168.com/dealermap/anhui/',
'https://faw-vw.che168.com/dealermap/beijing/',
'https://faw-vw.che168.com/dealermap/chongqing/',
'https://faw-vw.che168.com/dealermap/fujian/',
'https://faw-vw.che168.com/dealermap/guangdong/',
'https://faw-vw.che168.com/dealermap/guangxi/',
'https://faw-vw.che168.com/dealermap/henan/',
'https://faw-vw.che168.com/dealermap/hubei/',
'https://faw-vw.che168.com/dealermap/hunan/',
'https://faw-vw.che168.com/dealermap/hebei/',
'https://faw-vw.che168.com/dealermap/heilongjiang/',
'https://faw-vw.che168.com/dealermap/jiangsu/',
'https://faw-vw.che168.com/dealermap/jiangxi/',
'https://faw-vw.che168.com/dealermap/jilin/',
'https://faw-vw.che168.com/dealermap/liaoning/',
'https://faw-vw.che168.com/dealermap/namenggu/',
'https://faw-vw.che168.com/dealermap/ningxia/',
'https://faw-vw.che168.com/dealermap/shan_xi/',
'https://faw-vw.che168.com/dealermap/sichuan/',
'https://faw-vw.che168.com/dealermap/shanghai/',
'https://faw-vw.che168.com/dealermap/shanxi/',
'https://faw-vw.che168.com/dealermap/shandong/',
'https://faw-vw.che168.com/dealermap/tianjin/',
'https://faw-vw.che168.com/dealermap/xinjiang/',
'https://faw-vw.che168.com/dealermap/yunnan/',
'https://faw-vw.che168.com/dealermap/zhejiang/'
]

require 'json'
require 'pp'

def debug_exit(*item)
  dump item
  puts "========="*80
  exit
end

def debug(*item)
  dump item
  puts "========="*80
end

def dump(*item)
  #item.each do |i|
  # puts ""
  #end
  puts "-"*80
  pp item
end

  
urls.each do |url|
  str = "ruby builder.rb dazhong.yaml #{url}"
  puts str
  #puts `#{str}`
  #debug_exit `#{str}`
  debug `#{str}`
end



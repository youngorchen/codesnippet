require 'json'


puts "店名,url,姓名,地址,400电话".encode('gbk')

h = {}

Dir["*.json4"].each do |f|
 	a=JSON.parse(IO.read(f))

 	a["car_detail"].each do |k|
 		puts "#{k['seller']},#{k['url']},#{k['contact']},#{k['addr']},#{k['telphone']}".encode('gbk')
 	end 
end

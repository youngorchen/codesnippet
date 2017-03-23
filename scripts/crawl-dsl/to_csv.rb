require 'json'


puts "店名,姓名,400电话,短信回复内容".encode('gbk')

h = {}

Dir["*.json"].each do |f|
 	a=JSON.parse(IO.read(f))

 	a["data"].each do |k|
 		puts "#{a['mechant_name']},#{k['name'].split(' ')[1]},#{k['tel']},".encode('gbk')
 	end 
end

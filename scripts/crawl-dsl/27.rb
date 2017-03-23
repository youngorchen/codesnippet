require 'open-uri'


a=open("http://chain.273.cn/map/#shops_1","r:gbk").read
#a=open("273.html").read

#puts a

t= a.scan /\w+\.273\.cn/

urls = []
b = ''

puts "-"

t.each do |item|
        begin
                b = "http://#{item}/team"
                open(b) do |f|
                        urls << b
			puts "."
                end
        rescue
                puts b + "XXX"
                next
        end
end

puts urls

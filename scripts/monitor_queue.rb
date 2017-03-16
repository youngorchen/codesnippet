require 'rubygems'
require 'mechanize'
require 'pp'


def mail(title,str)
	%w(a b c).each do |to|
        puts `ruby /data/scripts/mail.rb  #{to} "#{title}" "#{str}" "./nothing"`
end

end

str = `ruby parse.rb | grep percentage`

str.each_line do |i|
	pp i
	if i =~ /(\d+)%/
		pp f = $1.to_f
		mail('网站改版预警',i) if f < 50
	end
end

#agent = Mechanize.new
#page = agent.get('http://ip/proxy')
str = `ruby -d proxy_jc.rb `
str.scan(/<a\s*href="(.*?)">/).each do |i|
	#pp i
	s = "curl -s \"#{i[0]}\""
	puts s
        str = `#{s}`
	puts str
        begin
		puts "........"
		str =~ /(\d+\.\d+\.\d+\.\d+)/m
		pp $1
		mail('网站代理预警',i[0]) unless $1 
	rescue
		mail('网站代理预警',i[0])
		next
	end 
end



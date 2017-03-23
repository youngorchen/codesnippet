require 'open-uri'

urls = open('273.txt').read

urls.each_line do |url|
	begin
		str = "ruby detail.rb #{url.strip} > #{url.scan(/\/\/(.*?)\./).flatten[0]}.json"
		puts str
		puts `#{str}`
	rescue
		puts url
		next
	end
end



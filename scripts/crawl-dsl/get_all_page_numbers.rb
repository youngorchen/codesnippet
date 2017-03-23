 require 'json'

a=JSON.parse(IO.read("a_city.txt"))

urls = []
a['cities'].each do |h|
	puts url = h["url"]
	urls << url
end

puts urls.length

urls.uniq.each do |url|
	url =~ /\/\/(.*?)\.273/
	name = $1
	puts name
	puts str = "ruby builder.rb list.yaml #{url} > #{name}.json1"
	puts `#{str}`
	#exit
end


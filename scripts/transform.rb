require 'pp'

IO.read("gemlist.txt").split(/\n/).each do |i|

 pp i
# sass (3.2.14, 3.2.13)
 
 next if not i =~ /(.*?)\s*\((.*?)\)/
 
 pp name = $1.strip
 puts $2

 $2.split(/,/).each do |j|
 	str = "gem install #{name} -v #{j}"
 	puts str
 	puts system(str)
 end
end



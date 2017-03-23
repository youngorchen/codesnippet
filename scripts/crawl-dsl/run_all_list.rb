require 'json'


sum = 0
Dir['*.json1'].each do |f|
  str = IO.read(f)
  #puts f
  n = 0
  #puts str
  if str =~ /RESULT.*"page_number":"(.*?)",/m
    n = $1.to_i
  end
  #puts n
  #exit
  sum += n
  f =~ /(.*)\.json1/
  name = $1
  puts "http://#{name}.273.cn/p[1..#{n}]/"
  
  (1..n).each do |i|
    url = "http://#{name}.273.cn/p#{i}"
    str = "ruby builder.rb list2.yaml #{url} > #{name}_#{i}.json2"
    puts str
    puts `#{str}`
    #exit
  end
end

puts sum
puts sum*20



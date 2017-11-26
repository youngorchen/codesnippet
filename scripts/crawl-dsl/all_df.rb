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

  
(1..149).each do |i|
  url = "https://yicheng.che168.com/dealermap/china/?page=#{i}"
  str = "ruby builder.rb df.yaml #{url}"
  puts str
  #puts `#{str}`
  #debug_exit `#{str}`
  debug `#{str}`
end



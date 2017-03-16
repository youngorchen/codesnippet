while true
 begin
  puts `ruby pingtime.rb www.baidu.com 300`
  #exit
  #sleep 2
 rescue
  next
 end
end


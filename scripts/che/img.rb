while true
t1=Time.now

puts `curl http://igj_big.jpg -o t.jpg;`

f = Time.now - t1

puts "=="*10+f.to_s
puts "X"*120 if f > 3
puts `ls -l t.jpg`
sleep rand(3)
end



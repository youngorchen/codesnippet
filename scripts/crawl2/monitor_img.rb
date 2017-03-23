require 'rubygems'
require 'mechanize'
require 'pp'
require 'redis'
require '/data/scripts/common_cfg'

def mail(title,str)
	%w(mailbox).each do |to|
        	puts `ruby /data/scripts/mail.rb  #{to} "#{title}" "#{str}" "./nothing"`
	end
end


webs = %w(g 5)
imgs = $r.keys "zt_*_img"


MAX = 10000
webs.each do |web|
  pp  str = "zt_#{web}_img"
  pp img_len = $r.llen(str)
  
  if img_len.to_i > 100
    puts "==============================> del ....." + str
    puts "del...del...del"

    puts img_len
    $r.del str
  end

  pp str = "zt_detail_#{web}"
  pp detail_len = $r.llen(str)

  if detail_len > MAX
    puts "==============================> del ....." + str
    #$r.del str
    n = detail_len - MAX
    pp n
    (1..n).each do |tt|
       puts "del...del...del"
       $r.rpop str
    end

    puts detail_len
  end

end



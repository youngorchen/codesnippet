require 'rubygems'
require 'mechanize'
require 'pp'
require 'redis'
require '/data/scripts/common_cfg'

def mail(title,str)
	%w(service@cyhz.com).each do |to|
        	puts `ruby /data/scripts/mail.rb  #{to} "#{title}" "#{str}" "./nothing"`
	end
end


webs = %w(ganji 168 58 baixing iautos taoche hx2car sohu 51auto)
imgs = $r.keys "zhihuantong_*_img"


MAX = 10000
webs.each do |web|
  pp  str = "zhihuantong_#{web}_img"
  pp img_len = $r.llen(str)
  
  if img_len.to_i > 100
    puts "==============================> del ....." + str
    puts "del...del...del"

    puts img_len
    $r.del str
  end

  pp str = "zhihuantong_detail_#{web}"
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



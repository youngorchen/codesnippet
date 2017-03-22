require 'json'
require 'pp'
require 'redis'
require '/data/scripts/common_cfg'

sum = 0

$r.keys('SCT_CRAWL_*del').each do |i|

  pp i

 while tt = $r.rpop(i)
  pp t = JSON.parse(tt)
  pp k = t['key']
  pp $r.del k # unless k =~ /c/ 
  #exit  if k =~ /c/
  #exit
  sum += 1
 end
end

pp sum




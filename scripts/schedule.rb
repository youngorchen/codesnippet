require 'rufus-scheduler'
#50 */1 * * * source /root/.bashrc; cd /data/scripts/R && R CMD BATCH ex1.R
#21 23 * * * source /root/.bashrc; cd /data/scripts && ruby -d parse.rb 
#*/2 * * * * cd /data/scripts && sh -x parse.sh >> a.log 2>&1


scheduler = Rufus::Scheduler.new

scheduler.cron '50 */1 * * *' do
  puts Time.now
  `cd /data/scripts/R && R CMD BATCH ex1.R`
end

scheduler.cron '21 23 * * *' do
  puts Time.now
  `cd /data/scripts && ruby -d parse.rb > a.log 2>&1`
end

scheduler.cron '55 */ * * *' do
  puts Time.now
  `cd /data/scripts && sh -x parse.sh >> a.log 2>&1`
end


#scheduler.every '1s' do
#  puts "Hello world"
#end

scheduler.join

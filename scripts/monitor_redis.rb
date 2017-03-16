require 'rubygems'
require 'mechanize'
require 'pp'
require 'redis'
require '/data/scripts/common_cfg'
require 'mysql2'
require 'active_record'

@adapter= "mysql2"
@host= "ip"
@database= "data_source"
@username= "user"
@password= "pwd"

def connect_db
  ActiveRecord::Base.establish_connection(
    :adapter  => @adapter,
    :host     => @host,
    :username => @username,
    :password => @password,
  :database => @database)

  ActiveRecord::Base.default_timezone = "Beijing"
  ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base.logger = Logger.new(STDOUT)
end

connect_db

class TTDB < ActiveRecord::Base
	self.table_name='redis_monitor'
end


def mail(title,str)
	%w(a b c).each do |to|
        	puts `ruby /data/scripts/mail.rb  #{to} "#{title}" "#{str}" "./nothing"`
	end
end


pp sp = $r.get('zhihuan_extractSpider')
pp ap = $r.get('zhihuan_extractApp')


d = TTDB.create :spider_number =>sp,:app_number =>ap

pp d.id

old = TTDB.find(d.id-1)

if d.spider_number.to_i - old.spider_number.to_i == 0
  mail('爬虫可能有问题',d.spider_number)
end

if d.app_number.to_i - old.app_number.to_i == 0
   mail('小库可能有问题',d.spider_number)
end

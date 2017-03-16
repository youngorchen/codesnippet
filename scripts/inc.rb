require 'rubygems'
require 'pp'
require 'json'
require 'redis'
require 'active_record'
require 'yaml'
require 'mysql2'
require '/data/scripts/common_cfg'

def connect_db   #Method is to connect DB
        ActiveRecord::Base.establish_connection(
        :adapter  => 'mysql2',
        :host     => 'ip',
#	:port => 3307,
        :username => 'user',
        :password => 'pwd',
        :database => 'shot')

        ActiveRecord::Base.default_timezone = "Beijing"
        #ActiveRecord::Base.pluralize_table_names = false
end

connect_db

class Download < ActiveRecord::Base
end

def get_ip(ip)
  require 'open-uri'
  open("http://ip:3333/ip/#{ip}").read
end


def update_db
  str = ARGV[2]

  Download.create :ip=>ARGV[1],:name=>ARGV[0],:location=>get_ip(ARGV[1]),:channel=>"s.cyhz.com_#{ARGV[2]}"
end

def inc

	$r.incr "jc_#{ARGV[0]}_download_counter"
end

#inc



update_db


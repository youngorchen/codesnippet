# -*- coding: UTF-8 -*-


require 'rubygems'
require 'mysql2'

require 'active_record'
require 'pp'
require 'date'

$con = nil

def connect_db   #Method is to connect DB
  if $M_DEBUG
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => 'ip',
      :username => 'ip',
      :password => 'ip',
      :database => 'ip',
    :port => 3306)

    ActiveRecord::Base.default_timezone = "Beijing"
    #ActiveRecord::Base.pluralize_table_names = false
  else
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2',
      :host     => 'pp',
      :username => 'ip',
      :password => 'ip',
      :database => 'ip',
    :port => 8004
    )

    ActiveRecord::Base.default_timezone = "Beijing"
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end
  $con = 'test'
end

connect_db unless $con

class CarSource < ActiveRecord::Base
  self.table_name = "car_source"
end

class Client < ActiveRecord::Base
  self.table_name = "client"
end

class SendQueue < ActiveRecord::Base
  self.table_name = "send_queue"
end


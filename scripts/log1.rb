require 'rubygems'
require 'active_record'
require 'yaml'
require 'pp'
require 'mysql2'
require 'json'
require 'redis'
require 'date'


@adapter= "mysql2"
@host= "ip"
@database= "db"
@username= "user"
@password= "pwd"


def connect_db
  ActiveRecord::Base.establish_connection(
    :adapter  => @adapter,
    :host     => @host,
    :username => @username,
    :password => @password,
  :database => @database)

  #  ActiveRecord::Base.default_timezone = "Beijing"
  ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.send(:inheritance_column=, 'runtime_class')

end

connect_db

class UserOperationLog < ActiveRecord::Base
  self.table_name= "info"
end

class CarInfo < ActiveRecord::Base
end

class UserInfoT < ActiveRecord::Base
end

pp CarInfo.find(3749397)

pp UserOperationLog.find(3749397)

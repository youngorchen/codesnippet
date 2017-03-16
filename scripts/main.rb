require 'rubygems'
require 'active_record'
require 'yaml'
require 'pp'
require 'mysql2'


def connect_db   #Method is to connect DB
	db_config = YAML.load(File.open("db_config.yaml"))    #Get congfigrat
#	pp db_config
	ActiveRecord::Base.establish_connection(
		:adapter  => db_config["adapter"],
        :host     => db_config["host"],
        :username => db_config["username"],
        :password => db_config["password"],
        :database => db_config["database"])

        ActiveRecord::Base.default_timezone = "Beijing"
	#ActiveRecord::Base.pluralize_table_names = false
end

connect_db

class History < ActiveRecord::Base
#	set_table_name "histories"
end

def update_history(arr)
	pp arr
	puts "==="*80
	arr.each do |t|
		item = History.new
		item.queue_name=t['destinationName']
		item.enque = t['EnqueueCount'].to_i
		item.deque = t['DequeueCount'].to_i
		
		item.save

#		pp item
 	end
end

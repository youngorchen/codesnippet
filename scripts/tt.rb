require 'rubygems'
require 'sinatra'
require "sinatra/basic_auth"
require 'open-uri'
require 'haml'
require 'json'
require 'yaml'
require 'pp'
require 'mysql2'
require 'redis'
require 'date'
require 'active_record'
require 'datagrid'


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
   # :port => 3307,
  :database => @database)

  #  ActiveRecord::Base.default_timezone = "Beijing"
  #ActiveRecord::Base.pluralize_table_names = false
  ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.send(:inheritance_column=, 'runtime_class')

end

connect_db

class Download  < ActiveRecord::Base
end

class DownloadReport
  include Datagrid

  scope do
    Download.all.order("created_at desc")
  end
  
  column :ip
  column :location
  column :created_at
  
end

get '/download' do 
    @download_report = DownloadReport.new(params[:download_report])
    #@assets = @download_report.assets.page(params[:page])
    erb :download    
end



#pp Download.find(3)

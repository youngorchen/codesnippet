require 'sinatra'
require 'slim'
require 'data_mapper'
require 'pp'
require 'cgi'


DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")


class Task
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :completed_at, DateTime
  belongs_to :list
end

class List
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  has n, :tasks, :constraint => :destroy  
end

DataMapper.finalize

get('/styles.css'){ content_type 'text/css', :charset => 'utf-8' ; scss :styles }

get '/' do
  #@lists = List.all(:order => [:name])
  #slim :index
  list = {}
  list['url'] = ''
  list['yaml'] = ''
  list['output'] = ''
  list['exception'] = ''
  
  slim :crawl,:locals => { :list => list }
end

def write_to_tmp_file(str,url)
  fn = "/data/scripts/crawl/builder/tmp/#{CGI.escape(url)}.yaml"
  open(fn,'w') { |f| f << str}
  return fn
end

post '/new/crawl' do
  pp list = params['list']
  #slim :crawl, :locals => { :list => list }
  #list['output'] = `ruby -e \'puts \"#{list['yaml']+'========!!!!!'}\"\'`
  #fn = '/data/scripts/crawl/builder/builder.rb'
  fn = write_to_tmp_file(list['yaml'],list['url'])
  str = "cd /data/scripts/crawl/builder ; ruby builder.rb #{fn} \"#{CGI.escape(list['url']).strip}\""
  pp str
  list['output'] = `#{str}`
  pp list
  slim :crawl ,:locals => { :list => list }
end

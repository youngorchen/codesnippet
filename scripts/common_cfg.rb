require 'pp'
require 'json'
require 'redis'

unless defined? $r
  $r = Redis.new :host => "x.x.x.X", :port => 6379   
end


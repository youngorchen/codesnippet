require 'rubygems'
require 'em-proxy'

Proxy.start(:host => "0.0.0.0", :port => 80, :debug => false) do |conn|
  conn.server :srv, :host => "ip", :port => 80

  # modify / process request stream
  conn.on_data do |data|
    p Time.now
    p [:on_data, data]
    data
  end
 
  # modify / process response stream
  conn.on_response do |backend, resp|
    p Time.now
     [:on_response, backend, resp]
    # resp = "HTTP/1.1 200 OK\r\nConnection: close\r\nDate: Thu, 30 Apr 2009 03:53:28 GMT\r\nContent-Type: text/plain\r\n\r\nHar!"
    resp
  end
end



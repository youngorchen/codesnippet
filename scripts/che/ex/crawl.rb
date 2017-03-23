require 'patron'

sess = Patron::Session.new
sess.timeout = 10
sess.base_url = "http://s"
sess.headers['User-Agent'] = 'myapp/1.0'
sess.enable_debug "/tmp/patron.debug"

resp = sess.get("/")

if resp.status < 400
  puts resp.body
end



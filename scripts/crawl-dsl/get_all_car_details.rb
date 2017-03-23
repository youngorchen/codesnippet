require 'json'
require 'pp'
require 'redis'
require '/data/scripts/common_cfg'


def get_proxy
  proxy = "curl http://ip/ips8/1"
  return $1 if proxy =~ /(\d+\.\d+.\d+.\d+:\d+)/m

  return '114.46.226.198:8088'
end

puts 
pp get_proxy

exit


Dir["*.json2"].each do |f|
	puts f
	str = IO.read(f)
	a = JSON.parse(str.split(/\n/)[-1])["cars"].map {|i| i["car_url"]}
	a.each do |url|
		cmd = "ruby builder.rb car_detail.yaml #{url} &"
		puts cmd
		#puts `#{cmd}`
		#system(cmd)
		$r.rpush("273_TASK",url)
		
	end

	sleep ARGV[0].to_i

	`mv #{f} #{f}.done`
	#exit
end


ip_list=%w(
	172.16.0.85
	172.16.0.86
	172.16.0.87
	172.16.0.88
	172.16.0.89

	172.16.0.90
	172.16.0.91
	172.16.0.92
	172.16.0.93
	172.16.0.94

	172.16.0.95
	172.16.0.96
	172.16.0.97
	172.16.0.98
	172.16.0.99

	172.16.0.100
	172.16.0.101
	172.16.0.102
	172.16.0.103
	172.16.0.104

	172.16.0.105
        172.16.0.106
        172.16.0.107
        172.16.0.108
        172.16.0.109

        172.16.0.110
        172.16.0.111
        172.16.0.112
        172.16.0.113
        172.16.0.114

	)

TIMES=1

def pingable?(addr)
  cmd = "ping -c #{TIMES} #{addr} 2>&1"
#puts cmd
  output = `#{cmd}`
#puts output
  res = true
  res = false if output.include? "100% packet loss"
  res = false if output.include?  "unknown host"
  res
end

#puts "Shizam!" if pingable? "google1.com"

def ping_result(ip)
	res = "."
	res = "X" unless pingable? ip

	puts "test #{ip}" + "."*20 + res
end

while true
	ip_list.each do |ip|
		ping_result(ip)
	end
	sleep 10
end

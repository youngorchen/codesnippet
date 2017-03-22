ip_list=%w(
	172.16.0.4
	172.16.0.5
	172.16.0.6
	172.16.0.7
	)

def pingable?(addr)
  cmd = "ping -c 2 #{addr} 2>&1"
#puts cmd
  output = `#{cmd}`
#puts output
  res = true
  res = false if output.include? "100% packet loss"
  res = false if output.include? "unknown host"
  res
end

#puts "Shizam!" if pingable? "google1.com"

def ping_result(ip)
	res = "OK"
	res = "X" unless pingable? ip

	puts "test #{ip}" + "."*20 + res
end

=begin
while true
	ip_list.each do |ip|
		ping_result(ip)
	end
	sleep 10
end
=end

require 'rush'
require 'pp'
require 'net/ssh'

def rexec(ip,password,cmd)
	str = ""
	Net::SSH.start(ip,"root",:password => password) do |ssh|
        ssh.exec!(cmd) do |channel,stream,data|
                    str << data if stream == :stdout
                    str << data if stream == :stderr
        end 
	end 
	str		
end

def get_runningvms(ip,passwd="v,")
	#cmd = "sshpass -p #{passwd} ssh root@#{ip} vboxmanage list vms | cut -d '\"' -f2"
	#str = Rush.bash(cmd)
	cmd = "vboxmanage list runningvms | cut -d '\"' -f2"
	str = rexec(ip,passwd,cmd)
	#pp str
	vms = []
	str.each_line do |i|
		vms << i.chomp
	end
	vms
end

def get_vms(ip,passwd="v,")
	#cmd = "sshpass -p #{passwd} ssh root@#{ip} vboxmanage list vms | cut -d '\"' -f2"
	#str = Rush.bash(cmd)
	cmd = "vboxmanage list vms | cut -d '\"' -f2"
	str = rexec(ip,passwd,cmd)
	#pp str
	vms = []
	str.each_line do |i|
		vms << i.chomp
	end
	vms
end

arr = []
ip_list.each do |ip|
	arr += get_runningvms(ip)
end

pp arr

ip_list.each do |ip|
	#pp ip
	get_vms(ip).each do |i|
		#pp i
		str = 'running' 
		str = 'x' unless arr.include?i  
		puts "#{ip} #{i} ... #{str}"
	end

	cmd = "ifconfig   | grep 'inet addr' " 
	cmd = "df -lh"
	puts rexec(ip,"zhang123,",cmd)
end



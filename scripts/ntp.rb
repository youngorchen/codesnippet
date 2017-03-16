require 'rubygems'
require 'rush'
require 'pp'
require 'net/ssh'

@ips = []
@vms = []

def rexec(ip,password,cmd,port=22)
	str = ""
	Net::SSH.start(ip,"root",:password => password,:port=>port) do |ssh|
        ssh.exec!(cmd) do |channel,stream,data|
                    str << data if stream == :stdout
                    str << data if stream == :stderr
        end 
	end 
	str		
end

(2..11).each do |i|
  @ips << "172.16.0.#{i}"
end


(85..114).each do |i|
  @vms << "172.16.0.#{i}"
end


def ntp
	@vms.each do |i|
    	puts i
    	#puts `sshpass -p "zhang123," ssh root@#{i} ntpdate asia.pool.ntp.org`
		puts rexec i,"1","ntpdate asia.pool.ntp.org"
	end
	@ips.each do |i|
		puts i
    	#puts `sshpass -p "c123456" ssh root@#{i} ntpdate asia.pool.ntp.org`
		puts rexec i,"c123456","ntpdate asia.pool.ntp.org"
	end
end


ntp

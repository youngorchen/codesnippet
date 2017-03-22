require 'rubygems'
require 'rush'
require 'pp'
require 'net/ssh'

ip_list=""

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

#load("ip_hook")

eval(IO.read("ip_hook"))

cmds = IO.read("cmds") if File.exists?("cmds")

pp ip_list.chomp!
pp cmds.chomp!

puts "pwd=#{ARGV[0]}"

ip_list.each_line do |ip| 
	ip = ip.chomp
	cmds.each_line do |cmd|
		next if cmd =~ /^\s*#/
		cmd=cmd.chomp.sub(/IP/,ip)
		puts "#{ip}--[#{cmd}]"
begin
		puts rexec(ip,ARGV[0],cmd,22)
rescue
	next
end
	end
	puts "="*80
end

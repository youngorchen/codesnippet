require 'pp'

@@hostname="TTTTT"
@@ip="127.0.0.1"

def get_input
  while true
    puts "enter hostame, ex vm1-opsnode5.y"
    str = gets.chomp
    if str != ""
      @@hostname = str
      break
    end
  end
  while true
    puts "enter ip, ex 172.16.0.93"
    str = gets.chomp
    if str != ""
      @@ip = str
      break
    end
  end  
  puts "hostname = #{@@hostname} and ip = #{@@ip}, please confirm...(y/n)"
  str = gets.chomp
  return if str == 'y'
  get_input if str == 'n'
end

def file_sub(file,pat,rep)
  puts pat
  str = IO.read(file)
  str = str.gsub(pat,rep)
  

  fh = File.new(file,"w")
  fh.puts str
  fh.close	
end

def view_file(file,pause=true)
  print "="*40
  print "   #{file}   "
  puts "="*40

  puts IO.read(file)

  if pause
    puts "press any key to continue..."
    gets
  end
end

get_input
exit

#view_file("/etc/rc.local")
#exit

#file_sub("test",/i/,"j")

#exit


i = 0

(1..10).each do |i|
	res = `ifcfg eth#{i} up 2>&1 | grep "Cannot find"`
	puts res
	if not res =~ /Cannot find/
		puts i
		break
	end
end

# change /etc/rc.local

rc_local=<<END_OF_RC

#!/bin/sh


touch /var/lock/subsys/local
ifup eth#{i}
ifup eth#{i+1}

END_OF_RC
puts rc_local



fh = File.new("/etc/rc.local","w")
fh.puts rc_local
fh.close


# change @@hostname
# /etc/sysconfig/network

file_sub("/etc/sysconfig/network",/@@hostname=.*$/,"@@hostname=#{@@hostname}")

# cd /etc/sysconfig/network-scripts
# cp ifcfg-eth0 to ethN
# 1...ethN+1

puts `cp /etc/sysconfig/network-scripts/eth0 /etc/sysconfig/network-scripts/ifcfg-eth#{i}`
puts `cp /etc/sysconfig/network-scripts/eth1 /etc/sysconfig/network-scripts/ifcfg-eth#{i+1}`


def rep_mac_i(n,i)
  mac_i = `cat /sys/class/net/eth#{i}/address`
  file_sub("/etc/sysconfig/network-scripts/ifcfg-eth#{i}",/eth#{n}/,"eth#{i}")
  file_sub("/etc/sysconfig/network-scripts/ifcfg-eth#{i}",/HWADDR=.*$/,"HWADDR=#{mac_i}")
  file_sub("/etc/sysconfig/network-scripts/ifcfg-eth#{i}",/IPADDR=.*$/,"IPADDR=#{@@ip}")
end

rep_mac_i(0,i)
rep_mac_i(1,i+1)


#if i != 0
#  `rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0`
#  `rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1`
#  sleep 100
#  `reboot`
#end


view_file("/etc/sysconfig/network-scripts/ifcfg-eth#{i}")
view_file("/etc/sysconfig/network-scripts/ifcfg-eth#{i+1}")

view_file("/etc/sysconfig/network")
view_file("/etc/rc.local")


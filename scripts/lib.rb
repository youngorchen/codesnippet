require '/data/scripts/common_cfg'

def get_ip(ip)
  str = ""
  pp ip if $DEBUG

  ip = ip.strip

  return ip if ip =~ /^172\./

  m = $r.get(ip)
  unless  m
    begin
      h =  JSON.parse(`curl "http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json&ip=#{ip}"`)
      str =  "#{h['province']}-#{h['city']}"
      if str.length < 3
        if `curl http://www.ip.cn/index.php?ip=#{ip}` =~ /来自：(.*)$/
		str = $1
	end
      end
      $r.set(ip,str)

      #str = `curl -s "http://wap.ip138.com/ip_search.asp?ip=#{ip}" | grep "查询结果："`
      #if str =~ /<b>查询结果：(.*)\s+.*<\/b>/
      #str = $1
      #pp str if $DEBUG
      #r.set(ip,str)
      #end
    rescue
      str = ip
    end
  else
    str =  m
  end
  #  pp str
  str
end

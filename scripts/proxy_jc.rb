require 'rubygems'
require 'pp'
require 'json'
require 'redis'
require 'open-uri'
require '/data/scripts/common_cfg'

def get_data

	h = {}

	h["url1"] = 'http://xx'
	

	[2,4,5,6,8].each do |n|
		h["fetch#{n}"] = $r.get "proxy_web#{n}_fetch"
		h["ok#{n}"] = $r.get "proxy_web#{n}_ok"
	  begin
		h["efftive#{n}"] = h["ok#{n}"].to_i*100/h["fetch#{n}"].to_i
	  rescue
	  	h["efftive#{n}"] = 0
	  end
                h["norm#{n}"] = $r.get "normal_ips_#{n}"
                h["ano#{n}"] = $r.get "anonymous_ips_#{n}"
                h["elite#{n}"] = $r.get "elite_ips_#{n}"
	end

	(1..8).each do |n|
		h["ips#{n}"] = $r.llen "ips#{n}"
	end

	#pp h
	h
end

def print_html(h)
	str = '<html><head><meta http-equiv="refresh" content="5" /></head><body>'

	str += '<table border="1" width="100%">'

	str += '<tr bgcolor="#ccccff">'
	str +="<th>网址</th><th>抓取条数</th><th>成功条数</th><th>成功率</th><th>透明ip数</th><th>匿名ip数</th><th>高匿名数</th>"
	str += "</tr>"

	str += "<tr>"
#	str += "<td><a href=\"#{h['url1']}\">url1</a></td><td>#{h['fetch1']}</td><td>#{h['ok1']}</td><td>#{h['efftive1']}%"
#        str += "</td><td>#{h['norm1']}</td><td>#{h['ano1']}</td><td>#{h['elite1']}</td>"
	str += "</tr>"

	str += "<tr>"
	str +="<td><a href=\"#{h['url2']}\">url2</a></td><td>#{h['fetch2']}</td><td>#{h['ok2']}</td><td>#{h['efftive2']}%</td>"
        str += "</td><td>#{h['norm2']}</td><td>#{h['ano2']}</td><td>#{h['elite2']}</td>"
	str += "</tr>"

#	str += "<tr>"
#	str +="<td><a href=\"#{h['url3']}\">url3</a></td><td>#{h['fetch3']}</td><td>#{h['ok3']}</td><td>#{h['efftive3']}%</td>"
#        str += "</td><td>#{h['norm3']}</td><td>#{h['ano3']}</td><td>#{h['elite3']}</td>"
#	str += "</tr>"

	str += "<tr>"
	str +="<td><a href=\"#{h['url4']}\">url4</a></td><td>#{h['fetch4']}</td><td>#{h['ok4']}</td><td>#{h['efftive4']}%</td>"
        str += "</td><td>#{h['norm4']}</td><td>#{h['ano4']}</td><td>#{h['elite4']}</td>"
	str += "</tr>"

	str += "<tr>"
	str +="<td><a href=\"#{h['url5']}\">url5</a></td><td>#{h['fetch5']}</td><td>#{h['ok5']}</td><td>#{h['efftive5']}%</td>"
        str += "</td><td>#{h['norm5']}</td><td>#{h['ano5']}</td><td>#{h['elite5']}</td>"
	str += "</tr>"

	str += "<tr>"
	str +="<td><a href=\"#{h['url6']}\">url6</a></td><td>#{h['fetch6']}</td><td>#{h['ok6']}</td><td>#{h['efftive6']}%</td>"
        str += "</td><td>#{h['norm6']}</td><td>#{h['ano6']}</td><td>#{h['elite6']}</td>"
	str += "</tr>"

	str += "<tr>"
	str +="<td><a href=\"#{h['url8']}\">url8</a></td><td>#{h['fetch8']}</td><td>#{h['ok8']}</td><td>#{h['efftive8']}%</td>"
        str += "</td><td>#{h['norm8']}</td><td>#{h['ano8']}</td><td>#{h['elite8']}</td>"
	str += "</tr>"


	#puts str
	str += "</table><br/><br/><br/><br/>"

	#new table

	str += '<table border="1" width="100%">'

	str += '<tr bgcolor="#ccccff">'
	str +="<th>name</th><th>pool size</th>"
	str += "</tr>"

	(1..8).each do |n|
		str += "<tr>"
		str +="<td>ips#{n}</td><td>"
		str += h["ips#{n}"].to_s
		str += "</td></tr>"
	end

	# str
	str+= "</table>"

	str += "</body></html>"
end



if $DEBUG
  h = get_data
  puts print_html(h)
end




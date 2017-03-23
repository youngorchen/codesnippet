 require 'json'

def proc_tel(tel)
	return '' unless tel
	
	#return tel if tel =~ /^AA/
	
	return tel.scan(/\d/).join.gsub(/^0/,'').gsub(/^86/,'')
end

#=begin
h = {}

Dir["*.json"].each do |f|
 	a=JSON.parse(IO.read(f))

	h["AA"+a["mechant_name"]] = a["data"].map {|k| k["tel"]}

end
#=end

#puts h 
#id 0 #城市1	车源类型2	站点3	车URL4	商户名称5	商户地址6	商户电话7	商户手机1-8	商户URL9	联系人10	联系人电话1-11	联系人电话2-12	联系人电话3-13	联系人手机1-14	联系人手机2-15	联系人手机3-16 车系-17,价格-18,上牌年-19,里程-20,排量-21，时间-22

str = IO.read(ARGV[0])
str.each_line do |line|
	#puts line
=begin	
	abc = line.split("\t")

	%w(7 8 11 12 13 14 15 16).each do |i|
			tel = abc[i.to_i].chomp.gsub(/\"/,"")
			tel = proc_tel(tel)
			h.each do |k,v|
				if v.index(tel)
					puts k
					puts "*******************"
				end
			end
	end
=end
	h.each do |k,v|
		v.each do |t|
			line=line.gsub(/#{t}/m,k)
		end
	end 
	puts line 
end


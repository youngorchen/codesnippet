# -*- coding: UTF-8 -*-

# 车辆品牌，大众全系，本田全系，日产全系，福特（嘉年华，福克斯，蒙迪欧，）丰田全系，斯柯达明锐，江淮瑞风，现代（途胜，胜达，IX35，索纳塔），斯巴鲁森林人，起亚（K5，智跑 狮跑）马自达6
# 车型，轿车，  SUV,   MPV,
# 年限，09以后
# 手车价格在30万以内

# 车辆价格在百万，年限13年  14年的进口豪车。

#brand,serie,year,price
def is_c_4_needed?(b,s,y,p)
	rules = [
		['大众','all','>=2009','<=30'],
		#['本田','all','>=2009','<=30'],
		#['日产','all','>=2009','<=30'],
		#['丰田','all','>=2009','<=30'],
		
		#['福特','嘉年华,福克斯,蒙迪欧','>=2009','<=30'],
		#['斯柯达','明锐','>=2009','<=30'],
		#['江淮','瑞风','>=2009','<=30'],
		#['现代','途胜,胜达,IX35,索纳塔','>=2009','<=30'],
		#['斯巴鲁','森林人','>=2009','<=30'],
		#['起亚','K5,智跑,狮跑','>=2009','<=30'],
		#['马自达','马自达6','>=2009','<=30'],

		#['all','all','>=2013',">=100"]
	]
	rules.each do |r|
		#puts r
		if r[0] == 'all'
			return true if eval("#{y} #{r[2]}") and eval("#{p} #{r[3]}")
		else
			if r[1] == 'all'
				return true if b =~ Regexp.new(r[0]) and eval("#{y} #{r[2]}") and eval("#{p} #{r[3]}")
			else
				return true if b =~ Regexp.new(r[0]) and s =~ Regexp.new(r[1]) and eval("#{y} #{r[2]}") and eval("#{p} #{r[3]}")
			end
		end
	end
	return false
end

def test(b,s,y,p)
	unless is_c_4_needed?(b,s,y,p)
		puts "X"
	else 
		puts "."
	end
end

#test('丰田','abc','2005','10')
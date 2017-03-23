# -*- coding: UTF-8 -*-

require './rule'

#bj
def c_3_filter(car)

  desc = car.desc || ""
  tel = car.phone

  if desc.index('背户') 
    puts "desc 里面有背户"
    puts desc
    puts "XX"*200
    return true
  end


  arr = ["外地牌","涿州牌","保定牌","天津牌","辽宁牌","山西牌","吉林牌","黑龙江牌","河北牌","黑户"]
  arr.each do |f1|
    if desc.index(f1) 
      puts "desc 里面有#{f1}"
      puts desc
      puts "XX"*200
      return true
    end
  end

  if car.city != '北京' 
    puts "不是北京车 对于客户 3"
    puts car.city
    puts "XX"*200
    return true
  end

#=begin
  if car and car.price.to_f < 20.0
    puts "价格低于 20万"
    puts car.price.to_f
    puts "XX"*200
    return true
  end
  
  if car and car.licenceDate and car.licenceDate.scan(/(.*)年/)[0][0].to_i < 2004
    puts "上牌时间太早"
    puts car.licenceDate.scan(/(.*)年/)[0][0].to_i
    puts "XX"*200
    return true
  end
#=end

#=begin
  puts "-- #{$redis.sismember('wx_mobiles_3',tel)} --"

  if $redis.sismember('wx_mobiles_3',tel) 
    puts "已经发过了！"
    puts tel
    puts "XX"*200
    return true 
  end
#=end

  return false
end

#haerbing


def c_4_filter(car)

  return false unless car
  
  desc = car.desc || ""
  tel = car.phone

  if desc.index('背户') 
    puts "desc 里面有背户"
    puts desc
    puts "XX"*200
    return true
  end



  if car.city != '哈尔滨' 
    puts "不是哈尔滨 对于客户 4"
    puts car.city
    puts "XX"*200
    return true
  end

  b = car.brand
  s = car.seies
  y = car.licenceDate.scan(/(.*)年/)[0][0].to_i 
  price = car.price
  
  unless is_c_4_needed?(b,s,y,price)
	puts "被过滤掉"
    puts b,s,y,price
    puts "XX"*200
    return true
  end
		
#=begin
  puts "-- #{$redis.sismember('wx_mobiles_4',tel)} --"

  if $redis.sismember('wx_mobiles_4',tel) 
    puts "已经发过了！"
    puts tel
    puts "XX"*200
    return true 
  end
#=end

  return false
end

#test only!

def c_5_filter(car)
	tel = car.phone
	return true if c_3_filter(car) and c_4_filter(car)
	
	
	puts "-- #{$redis.sismember('wx_mobiles_5',tel)} --"

	  if $redis.sismember('wx_mobiles_5',tel) 
		puts "已经发过了！"
		puts tel
		puts "XX"*200
		return true 
	  end
  
	return false
end

def c_6_filter(car)
	return true unless car
  
	desc = car.desc || ""
  
	tel = car.phone
	
	arr = ["外地牌","黑户"]
	arr.each do |f1|
		if desc.index(f1) 
		  puts "desc 里面有#{f1}"
		  puts desc
		  puts "XX"*200
		  return true
		end
	end
  
	puts "-- #{$redis.sismember('wx_mobiles_6',tel)} --"

	
	  if $redis.sismember('wx_mobiles_6',tel) 
		puts "已经发过了！"
		puts tel
		puts "XX"*200
		return true 
	  end
  
	return false
end


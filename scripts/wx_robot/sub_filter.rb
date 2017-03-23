# -*- coding: UTF-8 -*-

def sub_3_pass?(msg)
  #return true if msg['city'] == '北京'
  return false
end

def sub_4_pass?(msg)
  #return true if msg['city'] == '哈尔滨'
  return false
end


def sub_5_pass?(msg)
  return true if msg['city'] == '哈尔滨' or  msg['city'] == '北京'
  return false
end

def sub_6_pass?(msg)
#  %w(北京 上海 深圳 无锡 郑州).each do |c|
  %w(上海).each do |c|
  	return true if msg['city'] == c and msg['siteName'] != '51auto' and msg['phone'] =~ /1\d{10}/
  end 
  return false
end

require 'rubygems'
require 'rtesseract'
require 'pp'
require 'mini_magick'

def tran(s)
  s.gsub(/\s+/," ").strip.gsub(/\s+/,',')
end

pp ARGV
img = MiniMagick::Image.new(ARGV[0])

img.crop("#{img[:width]-50}x#{img[:height]-1}+50+0")

img = RTesseract.new(img.path)
pp tran(img.to_s)


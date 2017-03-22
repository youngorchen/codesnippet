require 'sinatra'
require 'active_record'
require File.dirname(__FILE__) + '/model'
require File.dirname(__FILE__) + '/xing'

class Web < Sinatra::Base
  get '/files' do
    puts params
    return "" if params[:pwd] != 'Hello'
    str = ""
    puts "===>"
    Contact.all.each do |i|
      puts i
      i.number = mobile_dec(i.number)
      i.name = xing_dec(i.name)

      str += "#{i.userid},#{i.name},#{i.number}\n"
    end
    body str
  end
end

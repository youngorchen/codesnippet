require 'rubygems'  
require 'sinatra'  
      
set :env,:production  
disable :run  
      
require './cy'  
      
# 在Sinatra的示例文档中是这样的: run Sinatra.application,但这样会报错的,修改后如下,正确启动.  
run Sinatra::Application  

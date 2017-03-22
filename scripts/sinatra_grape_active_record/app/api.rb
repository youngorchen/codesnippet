require 'grape'
require 'grape_entity'
require 'pp'

require File.dirname(__FILE__) + '/model'
require File.dirname(__FILE__) + '/xing'

class API < Grape::API
  version 'v1', using: :path
  format :json

  helpers do
    def authenticate(pwd)
      return true if pwd == 'Hello***'
      return false
    end

  end

  get :hello do
    {hello: "world==="}
  end

  resource :contacts do

    get ":id" do

      if authenticate(params[:pwd])
        Contact.where(:userid => params[:id]).each do |i|
          i.number = mobile_dec(i.number)
          i.name = xing_dec(i.name)
        end
      else
        Contact.where(:userid => params[:id])
      end

    end

    post do
      puts params
      #      puts request.env

      #authenticate
      userid= params[:userid]

      return "" if userid.to_i == 5

      content= params[:content]
      content.each do |i|

        y = mobile_enc(i[:number])

        t= Contact.find_by_userid_and_number(userid, y)
        x = xing_enc(i[:name])

        if t
          Contact.update(t.id, {
                           userid: userid,
                           name: x,
                           number: y,
                           r_id: i[:r_id]
          })
        else
          Contact.create!({
                            userid: userid,
                            name: x,
                            number: y,
                            r_id: i[:r_id]
          })
        end
      end
    end
  end
end



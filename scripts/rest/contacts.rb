module Contacts
  class API < Grape::API

    version 'v1', using: :path
    format :json

    resource :contacts do

      desc "Return a public timeline."
      get :timeline do
        "abc"
      end
    end
  end
end

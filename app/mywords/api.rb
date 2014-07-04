require 'grape'

module MyWords
  class API < Grape::API
    format :json

    get do
      {message: "mywords api"}
    end

    resource :freqlist do

      params do
        requires :access_token, type: String, desc: 'Facebook Access Token'
      end
      get ':login_user' do
      end
    end

  end
end



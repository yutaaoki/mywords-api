require 'grape'
require 'koala'
require './config'

module MyWords
  class API < Grape::API
    format :json

    Koala.config.api_version = "v2.0"

    helpers do
      def graph(access_token)
        Koala::Facebook::API.new access_token, AppConfig::APP_SECRET
      end
    end

    get do
      {message: "mywords api"}
    end

    resource :freqlist do

      params do
        requires :access_token, type: String, desc: 'Facebook Access Token'
      end
      get ':login_user' do
        _graph = graph(params[:access_token])
        allInboxes _graph, params[:login_user]
      end
    end

  end
end

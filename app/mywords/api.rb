require 'grape'
require 'koala'
require './config'
require_relative 'digger'

module MyWords
  class API < Grape::API
    format :json

    Koala.config.api_version = "v2.0"

    helpers Digger
    helpers AppConfig
    helpers do
      def _graph(access_token)
        Koala::Facebook::API.new access_token, AppConfig::APP_SECRET
      end
    end

    resource :api do

      get do
        {message: "mywords api"}
      end

      resource :messages do

        params do
          requires :access_token, type: String, desc: 'Facebook Access Token'
        end
        get ':login_user' do
          graph = _graph(params[:access_token])
          user = params[:login_user]
          inboxes = all_inboxes graph, user
          threads = thread_array inboxes
          messages = all_messages graph, threads, user 
          text = messages.join " "
          {data: text}
        end
      end
    end

  end
end

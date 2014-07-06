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
      # Create a graph object each time in order to
      # verify the user.
      def _graph(access_token)
        Koala::Facebook::API.new access_token, AppConfig::APP_SECRET
      end
    end

    resource :api do

      # Welcome message
      get do
        {message: "MyWords API"}
      end

      resource :messages do

        # Returns a json object containing a single string
        # combining all the messages found.
        params do
          requires :access_token, type: String, desc: 'Facebook Access Token'
        end
        get ':login_user' do
          # Create a graph object
          # This verifies the access token as well
          graph = _graph(params[:access_token])
          user = params[:login_user]

          # Get user inbox up to two pages
          inboxes = all_inboxes graph, user
          threads = thread_array inboxes

          # Look for user messages in each thread
          messages = all_messages graph, threads, user 

          # Make a single string
          text = messages.join " "
          {data: text}
        end
      end
    end

  end
end

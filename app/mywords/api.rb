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
        get 'me' do
          # Create a graph object
          graph = _graph(params[:access_token])
          # This will check if access_token is valid
          user = login_user graph

          # Get user inbox up to two pages
          inboxes = all_inboxes graph, user
          threads = user_threads inboxes, user

          # Look for user messages in each thread
          all_messages graph, threads, user 
        end

        get 'me/:friend' do
          # Create a graph object
          graph = _graph(params[:access_token])

          # This will check if access_token is valid
          me = login_user graph
          friend = params[:friend]

          # Get user inbox up to two pages
          inboxes = all_inboxes graph, me
          threads = user_threads inboxes, friend

          # Look for messages for both me and friend
          all_messages_friend graph, threads, [me, friend]
        end
      end

      resource :friends do

        params do
          requires :access_token, type: String, desc: 'Facebook Access Token'
        end
        get 'me' do
          # Create a graph object
          graph = _graph(params[:access_token])

          # This will check if the access token is valid
          user = login_user graph

          # Get user inbox up to two pages
          inboxes = all_inboxes graph, user

          friends_array inboxes, user
        end
      end
    # :api 
    end
  end
end

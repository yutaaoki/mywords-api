require './app/mywords/api'
require 'rack/test'
require './config'
require_relative 'shared_context'

describe MyWords::API do
   include Rack::Test::Methods
   include_context :api_context

   describe 'GET' do
     it "returns 200" do
       get '/api'
       assert_status(200)
     end
   end

   describe 'messages' do
     it 'returns text' do
       get 'api/messages/me?access_token='+AppConfig::ACCESS_TOKEN
       assert_status(200)
       puts last_response.body
     end
   end

   describe 'friends' do
     it 'returns text' do
       get 'api/friends/me?access_token='+AppConfig::ACCESS_TOKEN
       assert_status(200)
       puts last_response.body
     end
   end

end

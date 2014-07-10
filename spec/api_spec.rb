require './app/mywords/api'
require 'rack/test'
require './config'
require 'json'
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

   describe 'api/messages/me' do
     it 'returns json object' do
       get 'api/messages/me?access_token='+AppConfig::ACCESS_TOKEN
       assert_status(200)
       res = last_response.body
       result = JSON.parse(res)
       expect(result.kind_of?(Hash)).to eq(true)
       expect(result[AppConfig::USER_ID].length > 100).to eq(true)
     end
   end

   describe 'api/friends/me' do
     it 'returns text' do
       get 'api/friends/me?access_token='+AppConfig::ACCESS_TOKEN
       assert_status(200)
       res = last_response.body
       result = JSON.parse(res)
       expect(result.kind_of?(Array)).to eq(true)
       expect(result[0]['id'].nil?).to eq(false)
       #puts last_response.body
     end
   end

   describe 'api/messages/me/:friend' do
     it 'returns json object containing me and friend messages' do
       get 'api/messages/me/'+AppConfig::FRIEND_ID+'?access_token='+AppConfig::ACCESS_TOKEN
       res = last_response.body
       result = JSON.parse(res)
       expect(result.kind_of?(Hash)).to eq(true)
       expect(result[AppConfig::USER_ID].length > 100).to eq(true)
       expect(result[AppConfig::FRIEND_ID].length > 100).to eq(true)
     end
   end

end

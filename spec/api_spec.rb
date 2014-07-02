require './app/mywords/api'
require 'rack/test'
require_relative 'shared_context'

describe MyWords::API do
   include Rack::Test::Methods
   include_context :api_context


   describe 'GET' do
     it "returns 200" do
       get '/'
       expect(last_response.status).to eq(200)
     end
   end
end

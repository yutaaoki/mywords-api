require './app/mywords/api'
require 'rack/test'

describe MyWords::API do
   include Rack::Test::Methods

   def app
     MyWords::API
   end

   describe 'GET' do
     it "returns 200" do
       get '/'
       expect(last_response.status).to eq(200)
     end
   end
end

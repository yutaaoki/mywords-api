require 'grape'

module MyWords
  class API < Grape::API
    format :json

    get do
      {message: "mywords api"}
    end

  end
end



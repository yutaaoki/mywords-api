require 'moneta'
require 'cachy'

module MyWords
  module Digger

    def self.cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    def self.allInboxes(graph, login_user)
      cache.cache("inbox"+login_user, :expires_in => 1.hour){

        # Fetch the first page
        result = graph.get_connections("me", "inbox")

        # Fetch the next page. We won't fetch more than 
        # two pages so as not to pass the api limit.
        next_page = result.next_page

        # List of inbox objects
        all = []
        all.push result.first
        if next_page
          all.push next_page
        end
      }
    end

  end
end

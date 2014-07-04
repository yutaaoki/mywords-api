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
        all = []
        result = graph.get_connections("me", "inbox")
        all.push result.first
        next_page = result.next_page
        if next_page
          all.push next_page
        end
      }
    end

    def self.pages(cur)
      all = []
      page = cur.next_page
      all.push(page)
      if page.paging
        all.push(pages(cur))
      end
    end

  end
end

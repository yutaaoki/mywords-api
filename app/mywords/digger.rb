require 'moneta'
require 'cachy'

module MyWords
  module Digger

    def self.cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    def self.all_inboxes(graph, login_user)
      cache.cache("inbox"+login_user, :expires_in => 1.day){

        # Fetch the first page
        result = graph.get_connections("me", "inbox")

        # Fetch the next page. We won't fetch more than 
        # two pages so as not to pass the api limit.
        next_page = result.next_page

        # List of inbox objects
        all = []
        all.push result
        if next_page
          all.push next_page
        end
      }
    end

    def self.thread_array(inboxes)
      threads = []
      inboxes.each { |b| threads.concat(b) }
      threads
    end

    def self.user_threads(login_user, inboxes)
      inboxes.select do |e|
        if e['to'] && e['to']['data']
          contains = e['to']['data'].select { |d| d['id'] == login_user }
          !contains.empty?
        else
          false
        end
      end
    end

  end
end

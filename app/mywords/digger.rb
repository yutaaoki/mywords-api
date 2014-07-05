require 'moneta'
require 'cachy'

module MyWords
  module Digger

    def self.cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    MAX_THREADS = 30

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
      return threads
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

    def self.expand_threads(graph, threads, login_user)
      cache.cache("threads"+login_user, :expires_in => 1.day){
        all_threads = []
        count = 0

        # Recursively fetch threads
        threads.each do |t|
          if count >= MAX_THREADS
            break
          end
          thread = graph.get_objects(t['id'])
          count += 1
          threads.concat(thread_recursive threads, thread, count)
        end
        return all_threads
      }
    end

    def self.thread_recursive(threads, thread, count)

      if count >= MAX_THREADS
        return []
      end

      puts thread
      puts '------'
      next_page = thread.next_page
      if next_page['id']
        threads.concat(thread_recursive threads, next_page, count + 1)
      end
    end


  end
end

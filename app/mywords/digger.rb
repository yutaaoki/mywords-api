require 'moneta'
require 'cachy'

module MyWords
  module Digger

    def self.cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    MAX_COMMENTS = 2000
    MAX_DEPTH = 30

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

    def self.all_messages(graph, threads, login_user)
      cache.cache("messages"+login_user, :expires_in => 1.day){
        all_messages = []

        # Recursively fetch threads
        threads.each do |t|

          if all_messages.length > MAX_COMMENTS
            break
          end

          comments = graph.get_connections(t['id'], 'comments')
          all_messages = comments_recursive all_messages, comments, login_user, 1
        end

        all_messages
      }
    end

    def self.comments_recursive(all_messages, comments, user, depth)

      # Filter by user id
      user_comments = comments.select do  |com|
        if com['from']
          com ['from']["id"] == user
        else
          false
        end
      end

      # Only keep the message
      messages = user_comments.map do |com|
        if com['message']
          com['message']
        end
      end

      # Add this page to the array
      all_messages.concat(messages)

      # There's no further pages
      if depth >= MAX_DEPTH || !comments.methods.include?(:next_page)
        return all_messages
      end

      # There's a next page. Look for it recursively
      next_page = comments.next_page
      if next_page && !next_page.empty?
        comments_recursive all_messages, next_page, user, depth + 1
      else
        # There's no next page
        all_messages
      end
    end
  end
end

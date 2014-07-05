require 'moneta'
require 'cachy'

module MyWords
  module Digger

    def self.cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    MAX_COMMENTS = 200
    MAX_DEPTH = 2

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

    def self.all_comments(graph, threads, login_user)
      cache.cache("comments"+login_user, :expires_in => 1.day){
        all_comments = []

        # Recursively fetch threads
        threads.each do |t|
          if all_comments.length > MAX_COMMENTS
            break
          end
          comments = graph.get_connections(t['id'], 'comments')
          all_comments = comments_recursive all_comments, comments, login_user, 1
        end
        return all_comments
      }
    end

    #def self.threads_recursive(graph, threads, t_count, all_comments, com_count)
    #  thread = threads[t_count]
    #  if thread
    #      threads_recursive(graph, threads, t_count + 1, all_comments, com_count)
    ##  end
    #end

    def self.comments_recursive(all_comments, comments, user, depth)

      # Debug
      puts comments
      puts depth
      puts '-----'

      user_comments = comments.select do  |com|
        if com['from']
          com ['from']["id"] == user
        else
          false
        end
      end

      # Add this page to the array
      all_comments.concat(user_comments)

      puts all_comments.length

      # Look no further. Return the current array
      if depth >= MAX_DEPTH || !comments.methods.include?(:next_page)
        return all_comments
      end

      next_page = comments.next_page
      if next_page && !next_page.empty?
        comments_recursive all_comments, next_page, user, depth + 1
      else
        # There's no next page
        all_comments
      end
    end
  end
end

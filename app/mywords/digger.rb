require 'moneta'
require 'cachy'

# Fetches Facebook data using API
module MyWords
  module Digger
    include AppConfig

    module_function

    # Cache to store Facebook data
    def cache
      store = Moneta.new :File, dir: 'moneta'
      Cachy.cache_store = store
      Cachy
    end

    def login_user(graph)
      me = graph.get_object('me')
      me['id']
    end

    # Fetch user inbox up to two pages
    def all_inboxes(graph, login_user)
      cache.cache("inbox"+login_user, :expires_in => 1.day){

        # Fetch the first page
        result = graph.get_connections("me", "inbox")

        # Fetch the next page. We won't fetch more than 
        # two pages so as not to reach the api limit.
        next_page = result.next_page

        # List of inbox objects
        all = []
        all.push result
        if next_page
          all.push next_page
        end
        thread_array all
      }
    end

    # An inbox object is an array of threads.
    # This method convers an array of arrays into
    # a single array.
    def thread_array(inboxes)
      threads = []
      inboxes.each { |b| threads.concat(b) }
      return threads
    end

    # Filter out irrelevant threads based on
    # the user id.
    def user_threads(inboxes, user)
      inboxes.select do |e|
        if e['to'] && e['to']['data']
          contains = e['to']['data'].select { |d| d['id'] == user }
          !contains.empty?
        else
          false
        end
      end
    end

    # Featch as many messages as allowed by config.
    def all_messages(graph, threads, login_user)
      cache.cache("messages"+login_user, :expires_in => 1.day){
        # Array of all the messages. This object will contain
        # the return value at any given time.
        all_messages = {}

        # Process each thread object
        threads.each do |t|

          # We have enough messages now, so stop the loop.
          if all_messages.length > MAX_COMMENTS
            break
          end

          # Fetch the comment object the contains messages
          comments = graph.get_connections(t['id'], 'comments')
          all_messages = comments_recursive all_messages, comments, [login_user], 1, MAX_DEPTH
        end

        # Return the array of messages
        text_value all_messages
      }
    end

    def all_messages_friend(graph, threads, users)
      cache.cache("messages"+users[0]+"_"+users[1], :expires_in => 1.day){
        all_messages = {}
        threads.each do |thread|
          comments = graph.get_connections(thread['id'], 'comments')
          all_messages = comments_recursive all_messages, comments, users, 1, MAX_DEPTH_SINGLE
        end
        text_value all_messages
      }
    end

    def text_value(hash)
      result = {}
      hash.each do |key, value|
        result[key] = value.join " "
      end
      result
    end

    # Fetch comment objects recursively.
    # Store messages for multiple users.
    def comments_recursive(all_messages, comments, users, depth, max_depth)

      # Add messages to array
      users.each do |user|
        messages = user_messages comments, user
        # Initialise if nil
        all_messages[user] ||= []
        all_messages[user].concat(messages) unless messages.nil? 
      end

      # There's no further pages, so return a message array.
      if depth >= max_depth || !comments.methods.include?(:next_page)
        return all_messages
      end

      # There's a next page. Look for it recursively
      next_page = comments.next_page
      if next_page && !next_page.empty?
        comments_recursive all_messages, next_page, users, depth + 1, max_depth
      else
        # There's no next page, so return the message array.
        all_messages
      end
    end

    def user_messages(comments, user)
      # Filter out irrelevant comments
      user_comments = comments.select do  |com|
        if com['from']
          com ['from']["id"] == user
        else
          false
        end
      end
      # Only keep the message string because
      # a comment object contains other information
      messages = user_comments.map do |com|
        if com['message']
          com['message']
        end
      end
    end

    # Array of friend objects that have names and ids
    def friends_array(threads, user)
      friends = []
      threads.each do |t|
        if t['to'] && t['to']['data']
          t['to']['data'].each do |d|
            if d['id'] != user
              friends.push d
            end
          end
        end
      end
      friends.uniq{|e| e['id']}
    end

  end
end

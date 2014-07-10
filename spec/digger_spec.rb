require './app/mywords/digger'
require './config'


describe MyWords::Digger do
  include MyWords::Digger
  
  USER_ID = '10204429438402257'

  def graph()
    Koala::Facebook::API.new AppConfig::ACCESS_TOKEN, AppConfig::APP_SECRET
  end

  before(:each) do
    @inboxes = MyWords::Digger::all_inboxes graph, USER_ID
    @user_threads = MyWords::Digger::user_threads @inboxes, USER_ID
  end

  describe 'login_user' do
    it 'returns the user id' do
      user = MyWords::Digger::login_user graph
      expect(user).to eq(USER_ID)
    end
  end

  describe 'all_inboxes' do
    it 'returns all the inbox array' do
      expect(@inboxes.kind_of?(Array)).to eq(true)
      @inboxes.each do |box|
        expect(box.kind_of?(Hash)).to eq(true)
      end
      expect(@inboxes[0]['id'].kind_of?(String)).to eq(true)
    end
  end

  describe 'thread_array' do
    it 'returns thread array' do
      threads = MyWords::Digger::thread_array([[{}],[{}]]);
      expect(threads.kind_of?(Array)).to eq(true)
      threads.each do |t|
        expect(t.kind_of?(Hash)).to eq(true)
      end
    end
  end

  describe 'user_threads' do
    it 'returns user threads' do
      expect(@user_threads.empty?).to eq(false)
      @user_threads.each do |ut|
        contains = ut['to']['data'].select { |d| d['id'] == USER_ID }
        expect(contains.empty?).to eq(false)
      end
    end
  end

  describe 'all_messages' do
    it 'returns a message hash' do
      all_messages = MyWords::Digger::all_messages graph, @user_threads, USER_ID
      expect(all_messages.empty?).to eq(false)
      expect(all_messages.kind_of?(Hash)).to eq(true)
      expect(all_messages[USER_ID].length > 100).to eq(true)
    end
  end

  describe 'friends_array' do
    it 'returns a friend array' do
      friends = friends_array @user_threads, USER_ID
      #puts friends
      expect(friends.empty?).to eq(false)
      expect(friends.kind_of?(Array)).to eq(true)
    end
  end

  describe 'comments_recursive_multi' do
    it 'returns a messages hash' do
      friends = friends_array @user_threads, USER_ID
      data  = @user_threads[0]['to']['data']
      users = [data[0]['id'],data[1]['id']]
      all_messages = MyWords::Digger::all_messages_friend graph, @user_threads, users
      #puts all_messages
      expect(all_messages.empty?).to eq(false)
      expect(all_messages.kind_of?(Hash)).to eq(true)
      expect(all_messages[USER_ID].length > 100).to eq(true)
    end
  end
end

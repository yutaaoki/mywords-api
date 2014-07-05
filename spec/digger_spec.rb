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
    @threads = MyWords::Digger::thread_array @inboxes
    @user_threads = MyWords::Digger::user_threads USER_ID, @threads
  end

  describe 'all_inboxes' do
    it 'returns all the inbox objects' do
      expect(@inboxes.kind_of?(Array)).to eq(true)
      @inboxes.each do |box|
        expect(box.kind_of?(Array)).to eq(true)
      end
      expect(@inboxes[0][0]['id'].kind_of?(String)).to eq(true)
    end
  end

  describe 'thread_array' do
    it 'returns thread array' do
      expect(@threads.kind_of?(Array)).to eq(true)
      @threads.each do |t|
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
    it 'returns a message array' do
      all_messages = MyWords::Digger::all_messages graph, @user_threads, USER_ID
      expect(all_messages.empty?).to eq(false)
    end
  end
end

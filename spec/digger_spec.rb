require './app/mywords/digger'
require './config'


describe MyWords::Digger do
  
  USER_ID = '10204454169780526'

  def graph()
    access_token = 'CAALWvEqTcSMBAGW3vp0hZCwgepeFCmLWALSsFu0Kz0s5tIBmbpaqsYGtW0B0lIO3tbfM2ZBaxYTZClO6KZCPkG8dH1YWNkkAtd2Mrq1z5NVeRhRYFsZAaudIZCJpjfd84kbiD2ZCNx1RJVxgkc4eGqICThHu2f84Yt2kRcLv3EDcdQNgjSpbDvKLjz6gB3lcZC1CZCUxSwLSFfgZDZD'
    Koala::Facebook::API.new access_token, AppConfig::APP_SECRET
  end

  describe 'allInboxes' do
    it 'returns all the inbox objects' do
      result = MyWords::Digger::allInboxes graph, USER_ID
      expect(result.kind_of?(Array)).to eq(true)
      puts result[0]['id']
      expect(result[0]['id'].kind_of?(String)).to eq(true)
    end
  end

end

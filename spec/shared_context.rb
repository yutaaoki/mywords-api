shared_context :api_context do
  def app
    MyWords::API
  end

  def assert_status(code)
    expect(last_response.status).to eq(code)
  end
end

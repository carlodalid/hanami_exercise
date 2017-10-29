require 'api_helper'
require 'json'

describe 'GET /search' do
  params = '{"checkin":"in","checkout":"out","destination":"destination","guest":"guest"}'

  describe 'when given valid parameters' do
    it 'should be successful' do
      header 'Content-Type', 'application/json'
      post '/search', params

      expect(last_response).must_be :ok?
      expect(last_response.content_type).must_include 'application/json'
    end

    it 'should be empty by default' do
      header 'Content-Type', 'application/json'
      post '/search', params

      expect(last_response.body).must_equal '[]'
    end
  end
end

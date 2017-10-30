require 'api_helper'
require 'json'

describe 'GET /search' do
  supp_params       = '{"checkin":"in","checkout":"out","destination":"destination","guest":"guest","suppliers":"supplier1,supplier2"}'
  valid_params      = '{"checkin":"in","checkout":"out","destination":"destination","guest":"guest"}'
  incomplete_params = '{"checkin":"in","checkout":"out"}'
  invalid_params    = ''

  describe 'when given valid parameters' do
    it 'should be successful' do
      header 'Content-Type', 'application/json'
      post '/search', valid_params

      expect(last_response.status).must_equal 200
      expect(last_response.content_type).must_include 'application/json'
    end
  end

  describe 'when given incomplete parameters' do
    it 'should not be successful' do
      header 'Content-Type', 'application/json'
      post '/search', incomplete_params

      expect(last_response.status).must_equal 402
      expect(last_response.body).must_equal 'Bad Request'
    end
  end

  describe 'when given invalid parameters' do
    it 'should not be successful' do
      header 'Content-Type', 'application/json'
      post '/search', invalid_params

      expect(last_response.status).must_equal 402
      expect(last_response.body).must_equal 'Bad Request'
    end
  end

  describe 'when given params with suppliers' do
    it 'should be successful' do
      header 'Content-Type', 'application/json'
      post '/search', supp_params

      expect(last_response.status).must_equal 200
      expect(last_response.content_type).must_include 'application/json'
    end
  end
end

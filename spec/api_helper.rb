require_relative './spec_helper'

require 'rack/test'

class Minitest::Spec
  include Rack::Test::Methods

  def app
    Hanami.app
  end
end

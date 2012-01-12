require_relative 'helper'

Roy::Defaults.tap do |conf|
  conf[:prefix] = :http_
  conf[:use]    = [:after]
end

class DefaultsTestObject
  include Roy

  roy after: lambda { |response|
    response.status = 404
  }

  def http_get(path)
    'success'
  end
end

class DefaultsTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    DefaultsTestObject.new
  end

  def test_default_settings
    get '/'
    assert_equal 404, last_response.status
    assert_equal 'success', last_response.body
  end
end

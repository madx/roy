require_relative 'helper'

defaults = Roy::Defaults.dup
Roy::Defaults.prefix = :http_

class DefaultsTestObject
  include Roy

  def http_get(*args)
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
    assert_equal 'success', last_response.body
  end
end

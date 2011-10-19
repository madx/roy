require_relative 'helper'

class TestObject
  include Roy

  roy allow: [:get], prefix: :http_

  def http_get(*args)
    'success'
  end
end

class PrefixTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    TestObject.new
  end

  def test_prefixing
    get '/'
    assert_equal 'success', last_response.body
  end
end

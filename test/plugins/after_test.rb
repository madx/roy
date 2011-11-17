require_relative '../helper'
require 'roy/plugin/after'

class AfterTestObject
  include Roy
  include Roy::Plugin::After

  roy allow: [:get],
      after: lambda { |response|
        response.header['Content-Type'] = 'text/plain'
      }

  def get _
    'success'
  end
end

class AfterTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    AfterTestObject.new
  end

  def test_after_filter
    get '/'
    ok!
    assert_equal 'text/plain', last_response.header['Content-Type']
  end

end

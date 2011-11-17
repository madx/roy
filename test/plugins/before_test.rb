require_relative '../helper'
require 'roy/plugin/before'

class BeforeTestObject
  include Roy
  include Roy::Plugin::Before

  roy allow: [:get],
      before: lambda { |env|
        env['REQUEST_METHOD'] = 'GET'
      }

  def get(path)
    'success'
  end
end

class BeforeTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    BeforeTestObject.new
  end

  def test_before_filter
    post '/'
    ok!
    assert_equal 'success', last_response.body
  end

end

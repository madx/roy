
require_relative 'helper'

class CustomOptionsTestObject
  include Roy

  roy foo: :bar
end

class CustomOptionsTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    CustomOptionsTestObject.new
  end

  def test_custom_options
    assert_equal :bar, app.class.conf.foo
  end
end

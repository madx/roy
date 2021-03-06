require_relative '../helper'

class BasicAuthTestObject
  include Roy

  roy use: [:basic_auth], allow: [:get],
      auth: {
        realm: "Custom",
        logic: ->(_, u, p) { %w(user password) == [u, p] }
      }

  def get(path)
    roy.protected!
    'success'
  end
end

class BasicAuthTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    BasicAuthTestObject.new
  end

  def test_basic_auth_realm
    get '/'
    assert_match /Custom/, last_response['WWW-Authenticate']
  end

  def test_basic_auth_protected
    get '/'
    assert_equal 401, last_response.status
  end

  def test_basic_auth_authorized
    authorize 'user', 'password'
    get '/'
    ok!
  end

  def test_basic_auth_unauthorized
    authorize 'foo', 'bar'
    get '/'
    fail!
  end

end

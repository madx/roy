require_relative 'helper'

class RemoteLog
  include Roy

  attr_reader :history

  def initialize
    @history = []
  end

  roy allow: [:get, :put, :custom]

  def get(*args)
    history.inspect
  end

  def put(*args)
    Roy.halt 400 unless roy.params[:body]
    history << roy.params[:body]
    history << roy.params[:foo] if roy.params[:foo]
    get
  end

  def custom(*args)
    args.join('+')
  end
end

class RoyTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    RemoteLog.new
  end

  def test_provide_call
    assert_respond_to app, :call
  end

  def test_provide_roy
    assert_respond_to app.class, :roy
  end

  def test_forward_allowed_methods
    get '/'
    ok!
    assert_equal app.get, last_response.body
  end

  def test_block_forbidden_methods
    post '/'
    fail!
    assert_equal 405, last_response.status
  end


  def test_set_allowed_methods
    assert_includes app.class.conf.allow, :get
    assert_includes app.class.conf.allow, :put
    refute_includes app.class.conf.allow, :post
  end

  def test_allowing_get_allows_head
    assert_includes app.class.conf.allow, :head
  end

  def test_roy_halt
    assert_throws :halt do
      app.halt 200
    end
  end

  def test_head_does_not_have_contents
    head '/'
    ok!
    assert_equal '', last_response.body
  end

  def test_params
    put '/?foo=bar', :body => 'hello'
    ok!
    assert_equal %w(hello bar).inspect, last_response.body
  end

  def test_path_components_as_method_arguments
    request '/a/b/c', :method => 'CUSTOM'
    ok!
    assert_equal 'a+b+c', last_response.body
  end
end

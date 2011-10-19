require 'bundler'
Bundler.require(:default, :development)

require 'minitest/autorun'
require 'rack/test'
require 'roy'

module CustomTestMethods
  private

  def ok!
    assert_predicate last_response, :ok?
  end

  def fail!
    refute_predicate last_response, :ok?
  end
end

Rack::Test::Methods.send(:include, CustomTestMethods)

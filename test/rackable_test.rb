require 'rubygems'
require 'rack/test'
require 'bacon'

Bacon::Context.send :include, Rack::Test::Methods

class RestString
  include Rackable

  def initialize
    @string = "Hello, world!"
  end

  def get()
    @string
  end

  def put()
    if rack.data[:body]
      @string << rack.data[:body]
    else
      http_error 400
    end
  end

  def delete()
    if rack.query[:p]
      if @string =~ (rx = Regexp.new(rack.query[:p]))
        @string.gsub!(rx, '')
      else
        http_error 404, "Pattern #{rx.inspect} not found"
      end
    else
      @string = ""
    end
  end
end

class Redirecter
  extend Rackable

  def self.get
    rack.response.redirect('http://google.com')
    "hello"
  end
end

describe Rackable do
  before do
    def app
      RestString.new
    end
  end

  it 'provides a call() method' do
    app.should.respond_to :call
  end

  it 'calls the appropriate method on the racked object' do
    get '/'
    last_response.should.be.ok
    last_response.body.should == app.get
  end

  it 'enables HEAD requests if get is defined' do
    head '/'
    last_response.should.be.ok

    class RestString; undef_method :get; end

    head '/'
    last_response.should.not.be.ok

    class RestString; def get() @string; end end
  end

  it 'catches errors thrown inside the method' do
    put '/'
    last_response.status.should == 400
    last_response.body.should   == 'Bad Request'

    delete '/?p=nil'
    last_response.status.should == 404
  end

  it 'throws a 405 when the method is not defined' do
    post '/'
    last_response.status.should == 405
    last_response.headers['Allow'].should.not.include?('POST')
    last_response.headers['Allow'].should.    include?('GET')
  end

  it 'throws a 400 on argument errors' do
    get '/fail'
    last_response.status.should == 400
  end

  it 'prevents calling methods other than the allowed ones' do
    request '/%22foo%22', "REQUEST_METHOD" => "INSTANCE_EVAL"
    last_response.status.should == 405
  end

  describe 'Called method' do
    before do
      def app() Redirecter end
    end

    it 'can modify the response' do
      get '/'

      last_response.headers['Location'].should == 'http://google.com'
      last_response.status.should == 302
    end
  end
end

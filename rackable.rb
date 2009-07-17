# Rackable is a tiny module that aims to provide a REST-like interface to
# any object and make it usable with Rack.
#
# I really don't know if this is useful, but it's more a proof of concept than
# anything.
module Rackable
  attr_accessor :response, :env,  :header
  attr_reader   :request,  :data, :query

  def call(env)
    @env      = env
    @request  = Rack::Request.new(env)
    @response = Rack::Response.new
    @header   = response.header
    @query    = request.GET.inject({})  {|h, (k,v)| h[k.to_sym] = v; h }
    @data     = request.POST.inject({}) {|h, (k,v)| h[k.to_sym] = v; h }

    method = env['REQUEST_METHOD'].downcase.to_sym

    args = env['PATH_INFO'][1..-1].split('/').collect { |arg|
      Rack::Utils.unescape(arg)
    }

    method, was_head = :get, true if method == :head

    status, body = catch(:halt) do
      begin
        [200, send(method, *args)]

      rescue NoMethodError
        header['Allow'] = [:get, :post, :put, :delete].delete_if { |meth|
          !respond_to?(meth)
        }.tap {|a|
          a.unshift 'HEAD' if respond_to? :get
        }.map { |meth|
          meth.to_s.upcase
        }.join(', ')

        http_error 405

      rescue ArgumentError
        http_error 400

      end
    end

    response.status = status
    response.write(body) unless was_head
    response.finish
  end

  private

  def http_error(code, message=nil)
    throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
  end

end


if $0 =~ /bacon$/
  require 'rubygems'
  require 'rack/test'

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
      if data[:body]
        @string << data[:body]
      else
        http_error 400
      end
    end

    def delete()
      if query[:p]
        if @string =~ (rx = Regexp.new(query[:p]))
          @string.gsub!(rx, '')
        else
          http_error 404, "Pattern #{rx.inspect} not found"
        end
      else
        @string = ""
      end
    end
  end

  def app
    RestString.new
  end

  describe Rackable do
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
  end

end

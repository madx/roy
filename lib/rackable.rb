module Rackable
  attr_reader :rack

  class MethodNotAllowed < NoMethodError
  end

  def call(env)
    _ra_prepare(env)

    method = rack.env['REQUEST_METHOD'].downcase.to_sym
    path   = rack.env['PATH_INFO']
    args   = _ra_split_path(path)

    method, was_head = :get, true if method == :head

    rack.response.status, body = _ra_method_call(method, args)

    rack.response.write(body) unless was_head
    rack.response.finish
  end

  private

  def http_error(code, message=nil)
    throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
  end

  def _ra_prepare(env)
    @rack = Struct.new(:env, :request, :response, :header, :query, :data).new
    rack.env = env

    rack.request  = Rack::Request.new(env)
    rack.response = Rack::Response.new
    rack.header   = rack.response.header

    rack.query = rack.request.GET.inject({})  {|h, (k,v)| h[k.to_sym] = v; h }
    rack.data  = rack.request.POST.inject({}) {|h, (k,v)| h[k.to_sym] = v; h }
  end

  def _ra_split_path(path)
    args = path.split(/\/+/).collect { |arg|
      Rack::Utils.unescape(arg)
    } || []
    args.empty? or args.first.empty? and args.shift

    args
  end

  def _ra_method_call(method, args)
    allowed_methods = [:get, :put, :post, :delete]

    rack.response.status, body = catch(:halt) do
      begin
        raise MethodNotAllowed unless allowed_methods.include? method
        body = send(:"http_#{method}", *args)
        [rack.response.status, body]

      rescue MethodNotAllowed
        rack.header['Allow'] = allowed_methods.delete_if { |meth|
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
  end
end

require 'set'
require 'rack'
require 'roy/version'

module Roy
  Env = Struct.new(:env, :request, :response, :headers, :params, :conf)

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def roy
    @roy ||= Env.new.tap {|e|
      e.conf = self.class.conf
    }
  end

  def call(env)
    roy.tap { |e|
      e.env      = env
      e.request  = Rack::Request.new(env)
      e.response = Rack::Response.new
      e.headers  = e.response.header
      e.params   = e.request.GET.merge(e.request.POST)
      e.params.default_proc = proc do |hash, key|
        hash[key.to_s] if Symbol === key
      end
    }

    method = roy.env['REQUEST_METHOD'].downcase.to_sym
    args = roy.env['PATH_INFO'].sub(/^\/+/, '').split(/\/+/).map { |arg|
      Rack::Utils.unescape(arg)
    }

    method, was_head = :get, true if method == :head

    roy.response.status, body = catch(:halt) do
      halt(405) unless roy.conf.allow.include?(method)
      prefixed_method = :"#{roy.conf.prefix}#{method}"
      [roy.response.status, send(prefixed_method, *args)]
    end

    roy.response.write(body) unless was_head
    roy.response.finish
  end

  def halt(code, message=nil)
    throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
  end

  module ClassMethods
    attr_reader :conf

    def roy(options={})
      @conf       ||= Struct.new(:allow, :prefix).new
      conf.allow  ||= Set.new
      conf.prefix ||= :''

      options.each do |k,v|
        case k
        when :allow
          conf.allow.merge(v)
          conf.allow.add(:head) if v.member?(:get)
        when :prefix
          conf.prefix = v
        end
      end
    end
  end
end

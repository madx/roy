# external dependencies
require 'rack'

# stdlib dependencies
require 'set'
require 'ostruct'

# local dependencies
require 'roy/version'

module Roy
  Env = Struct.new(:env, :request, :response, :headers, :params, :conf)
  Defaults = OpenStruct.new(allow: Set.new, prefix: :'')

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
    roy.env['PATH_INFO'].sub!(/^([^\/])/, '/\1')

    method, was_head = :get, true if method == :head

    roy.response.status, body = catch(:halt) do
      halt(405) unless roy.conf.allow.include?(method)
      prefixed_method = :"#{roy.conf.prefix}#{method}"
      [roy.response.status, send(prefixed_method, roy.env['PATH_INFO'])]
    end

    roy.response.write(body) unless was_head
    roy.response.finish
  end

  def halt(code, message=nil)
    throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
  end

  module ClassMethods
    attr_reader :conf

    def self.extended(base)
      base.instance_eval { @conf ||= Defaults.dup }
    end

    def roy(options={})
      options.each do |key,value|
        case key
        when :allow
          conf.allow.merge(value)
          conf.allow.add(:head) if value.member?(:get)
        when :use
          value.each do |name|
            if name.is_a?(Symbol)
              require "roy/#{name}"
              const = "#{name}".capitalize.gsub(/_(\w)/) {|m| m[1].upcase }.to_sym
              name = Roy.const_get(const)
            end
            include name
          end
        else
          conf.send(:"#{key}=", value)
        end
      end
    end
  end
end

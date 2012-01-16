# external dependencies
require 'rack'

# stdlib dependencies
require 'set'
require 'ostruct'

# local dependencies
require 'roy/version'

module Roy
  Defaults = {allow: [:get], prefix: :'', use: [:halt]}

  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  def roy
    @roy ||= OpenStruct.new.tap {|r|
      r.app  = self
      r.conf = self.class.conf
      self.class.ancestors.reverse.each do |mod|
        mod.setup(r) if mod.respond_to?(:setup)
      end
    }
  end

  def call(env)
    roy.tap { |r|
      r.env      = env
      r.request  = Rack::Request.new(env)
      r.response = Rack::Response.new
      r.headers  = r.response.header
      r.params   = r.request.GET.merge(r.request.POST)
      r.params.default_proc = proc do |hash, key|
        hash[key.to_s] if Symbol === key
      end
    }

    method = roy.env['REQUEST_METHOD'].downcase.to_sym
    roy.env['PATH_INFO'].sub!(/^([^\/])/, '/\1')

    method, was_head = :get, true if method == :head

    roy.response.status, body = catch(:halt) do
      roy.halt(405) unless roy.conf.allow.include?(method)
      prefixed_method = :"#{roy.conf.prefix}#{method}"
      [roy.response.status, send(prefixed_method, roy.env['PATH_INFO'])]
    end

    roy.response.write(body) unless was_head
    roy.response.finish
  end

  module ClassMethods
    attr_reader :conf

    def self.extended(base)
      base.instance_eval do
        @conf ||= OpenStruct.new
        roy Defaults
      end
    end

    def roy(options={})
      options.each do |key,value|
        case key
        when :allow
          (conf.allow ||= Set.new).merge(value)
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

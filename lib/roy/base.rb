# external dependencies
require 'rack'

# stdlib dependencies
require 'set'
require 'ostruct'

# local dependencies
require 'roy/version'
require 'roy/context'

# This is the main module that applications should include.
module Roy

  # Default options.
  Defaults = {allow: [:get], prefix: :'', use: [:halt]}

  # Extend the class with the ClassMethods module.
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  # Returns the application context or initialize it
  def roy
    @roy ||= Context.new(self)
  end

  # A Rack-compliant #call method.
  def call(env)
    roy.prepare!(env)

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

    # Setup default configuration for the application.
    def self.extended(base)
      base.instance_eval do
        @conf ||= OpenStruct.new
        roy Defaults
      end
    end

    # Set options for the application
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

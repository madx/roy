module Roy
  # This module adds a +halt+ method to the application context that allows you
  # to break during a handler and immediately return a status code and a body.
  #
  # Included by default.
  #
  # @example A Not Found application
  #
  #   class NotFoundApp
  #     include Roy
  #
  #     def get(_)
  #       halt 404
  #     end
  #   end
  #
  # @example Test
  #
  #   $ curl -i localhost:9292
  #   HTTP/1.1 404 Not Found
  module Halt

    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods
      # Break from the current +catch(:halt)+ block
      #
      # @param [Integer] code the response status code.
      # @param [String] message the response body.
      # @return [Integer, String] the status and the given message or a default
      #   one.
      def halt(code, message=nil)
        throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
      end
    end

  end
end

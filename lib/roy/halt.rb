module Roy
  module Halt

    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods
      def halt(code, message=nil)
        throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
      end
    end

  end
end

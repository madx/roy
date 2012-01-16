module Roy
  module Halt

    def self.setup(roy)
      class << roy
        def halt(code, message=nil)
          throw :halt, [code, message || Rack::Utils::HTTP_STATUS_CODES[code]]
        end
      end
    end

  end
end

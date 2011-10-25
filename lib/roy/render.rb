require 'tilt'

module Roy
  module Render

    def render(engine, view_or_string, params={}, &block)
      tilt = case view_or_string
      when Symbol
        file = [view_or_string.to_s, engine].map(&:to_s).join('.')
        dir = roy.conf.views || 'views'
        Tilt.new(File.join(dir, file))
      else
        Tilt[engine].new { view_or_string.to_s }
      end

      tilt.render(self, params, &block)
    end

  end
end

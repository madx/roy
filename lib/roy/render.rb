require 'tilt'

module Roy
  module Render

    def render(engine, view_or_string, params={}, &block)
      options = roy.conf.render || {}
      template = case view_or_string
        when Symbol
          file = [view_or_string.to_s, engine].map(&:to_s).join('.')
          dir = roy.conf.views || 'views'
          Tilt.new(File.join(dir, file), nil, options)
        else
          Tilt[engine].new(nil, nil, options) { view_or_string.to_s }
        end

      template.render(self, params, &block)
    end
  end
end

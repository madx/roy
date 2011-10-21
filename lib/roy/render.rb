require 'tilt'

module Roy
  module Render
    def render(engine, template_or_string, params={}, &block)
      case template_or_string
      when Symbol
      else
        Tilt[engine].new {
          template_or_string.to_s
        }.render(self, params, &block)
      end
    end
  end
end

require 'tilt'

module Roy
  # A simple template rendering mechanism based on Tilt.
  #
  # == Related options:
  # roy.conf.render::
  #   A hash of options to pass to Tilt.
  # roy.conf.views::
  #   The directory where views are kept.
  #
  # @example Using <tt>roy.render</tt>
  #
  #   class ErbApp
  #     include Roy
  #
  #     roy use: [:render]
  #
  #     def get(_)
  #       roy.render :erb, "Hello, <%= roy.params[:p] || \"world\" %>!\n"
  #     end
  #   end
  #
  # @example Test
  #
  #   $ curl -i localhost:9292
  #   Hello, world!
  #   $ curl -i localhost:9292/?p=blah
  #   Hello, blah!
  module Render

    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods
      def render(engine, view_or_string, params={}, &block)
        options = conf.render || {}
        template = case view_or_string
          when Symbol
            file = [view_or_string.to_s, engine].map(&:to_s).join('.')
            dir = conf.views || 'views'
            Tilt.new(File.join(dir, file), nil, options)
          else
            Tilt[engine].new(nil, nil, options) { view_or_string.to_s }
          end

        template.render(app, params, &block)
      end
    end

  end
end

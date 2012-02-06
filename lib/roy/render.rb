require 'tilt'

module Roy
  # A simple template rendering mechanism based on Tilt.
  #
  # == Configuration:
  # roy.conf.render::
  #   A hash of options to pass to Tilt.
  # roy.conf.views::
  #   The directory where views are kept. Defaults to +views/+
  #
  # @example Using <tt>roy.render</tt>
  #
  #   class ErbApp
  #     include Roy
  #
  #     roy use: [:render]
  #
  #     def get(path)
  #       case path
  #       when /\/hello/
  #         roy.render :erb, "Hello, <%= roy.params[:p] || \"world\" %>!\n"
  #       else
  #         roy.render :erb, :index
  #       end
  #     end
  #   end
  #
  # @example Test
  #
  #   $ cat views/index.erb
  #   Let me <a href="/hello">greet</a> you.
  #   $ curl -i localhost:9292
  #   Let me <a href="/hello">greet</a> you.
  #   $ curl -i localhost:9292/hello?p=blah
  #   Hello, blah!
  #
  # @example Haml renderer with partials support
  #
  #   module HamlRenderWithPartial
  #     def self.setup(roy)
  #       roy.send(:extend, InstanceMethods)
  #     end
  #
  #     module InstanceMethods
  #       def render(tpl_or_string, params={})
  #         case layout = params.delete(:layout)
  #         when false
  #           super(:haml, tpl_or_string, params)
  #         else
  #           super(:haml, :layout, params do
  #             super(:haml, tpl_or_string, params)
  #           end
  #         end
  #       end
  #     end
  #   end
  module Render

    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods

      # Render the given template or string with the selected engine.
      #
      # Views are looked for inside the +roy.conf.views+ directory.
      # Files should have an extension matching the selected engine.
      # If you want to use sub-directories, you have to use the
      # +:"subdir/file.ext"+ syntax.
      #
      # @see https://github.com/rtomayko/tilt/blob/master/README.md
      # @see https://github.com/rtomayko/tilt/blob/master/TEMPLATES.md
      #
      # @param [Symbol] engine the name of the rendering engine. Must be
      #   supported by Tilt.
      # @param [Symbol] view_or_string a template file.
      # @param [String] view_or_string a template string.
      # @param [Hash] params locals for Tilt::Template#render.
      # @param [Proc] block a block to execute when using +yield+ in the
      #   template.
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

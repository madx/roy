# Rackable

Rackable is a tiny module that aims to provide a REST-like interface to
any object and make it usable with Rack.

## Specs

You can run the specs by running `bacon` on the `rackable.rb` file.

## Example

Here's a short example of what you can do with Rackable. This example is
actually used as a test app in the specs.

    require File.join(File.dirname(__FILE__), 'rackable')

    class RestString
      include Rackable

      def initialize
        @string = "Hello, world!"
      end

      def get()
        @string
      end

      def put()
        if data[:body]
          @string << data[:body]
        else
          http_error 400
        end
      end

      def delete()
        @string = ""
      end

    end

    run RestString.new

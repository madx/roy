# Rackable

Rackable is a tiny module that aims to provide a REST-like interface to
any object and make it usable with Rack.

Basically, what it does is providing an object with a `call()` method that
uses the Rack environement to dispatch to a method, giving helper objects such
as headers, query parameters, ...

## Specs

You can run the specs by running `bacon` on the `rackable.rb` file.
Bacon is available at
[chneukirchen/bacon](/chneukirchen/bacon "Bacon's GitHub repository")

## Example

Here's a short example of what you can do with Rackable. This example is
actually used as a test app in the specs.
Save this in a `.ru` file and `rackup`-it.

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

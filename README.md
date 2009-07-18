# Rackable

Rackable is a tiny module that aims to make any Ruby object Rack-friendly and
provide it with a REST-like interface.

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
        if rack.data[:body]
          @string << rack.data[:body]
        else
          http_error 400
        end
      end

      def delete()
        @string = ""
      end

    end

    run RestString.new

## Docs

Rackable provides a `rack` readable attribute which is a struct containing the
following fields:

* `env`: the parameter for `call`
* `response`: a `Rack::Response` object that is returned by `call`
* `header`: a hash of headers that is part of `response`
* `request`: a `Rack::Request` created from the environement given to `call`
* `query`: a hash of parameters extracted from the query string
* `data`: a hash of parameters extracted from the request body (POST, PUT)

For both `query` and `data`, keys of the hash are symbols.

You can easily handle errors with the provided `http_error` method. It takes an
error code and an optional message. If no message is given, the standard message
from the HTTP Status Codes list will be used (eg. Not Found for 404)

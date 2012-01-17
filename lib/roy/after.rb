module Roy
  # This module allows you to modify the response before it is sent to the
  # client. It does this by overriding the {Roy#call} method.
  #
  # == Related options:
  # roy.conf.after::
  #   A proc object that will be called with the response as argument.
  #   Defaults to identity if not set.
  #
  # @example Forcing a custom content-type
  #
  #   class SetContentType
  #     include Roy
  #
  #     roy use: [:after],
  #         after: ->(resp) { resp.headers['Content-Type'] = 'text/x-foo' }
  #
  #     def get(_)
  #       "Hello, world\n"
  #     end
  #   end
  #
  # @example Demo
  #
  #   $ curl -i localhost:9292
  #   HTTP/1.1 200 OK
  #   Content-Type: text/x-foo
  module After
    def call(env)
      status, header, body = super
      resp = Rack::Response.new(body, status, header)
      (roy.conf.after || lambda {|x| x }).(resp)
      resp.finish
    end
  end
end

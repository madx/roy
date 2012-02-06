module Roy
  # This module allows you to modify the environment before it is handled by the
  # application. It does this by overriding the {Roy#call} method.
  #
  # == Configuration:
  # roy.conf.before::
  #   A proc object that will be called with the environment as argument.
  #   Defaults to identity if not set.
  #
  # @example Forcing a method
  #
  #   class AlwaysGet
  #     include Roy
  #
  #     roy allow: [:put, :post], use: [:before],
  #         before: ->(env) { env['REQUEST_METHOD'] = 'GET' }
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
  #   $ curl -X POST -i localhost:9292
  #   HTTP/1.1 200 OK
  #   $ curl -X PUT -i localhost:9292
  #   HTTP/1.1 200 OK
  module Before
    def call(env)
      (roy.conf.before || lambda {|x| x }).(env)
      super
    end
  end
end

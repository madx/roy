module Roy
  # This module provides helpers for using the HTTP basic authentication system.
  #
  # == Configuration:
  # roy.conf.auth [:realm]::
  #   The authentication realm to use.
  # roy.conf.auth [:logic]::
  #   A proc that checks if an user is authorized. See #authorized? in
  #   InstanceMethods.
  #
  # @example Simple auth example
  #
  #   class AuthApp
  #     include Roy
  #     roy use: [:basic_auth],
  #         auth: {
  #           realm: "My Realm",
  #           logic: ->(_, u, p) { %w(admin foobar) == [u, p] }
  #         }
  #
  #     def get(_)
  #       roy.protected!
  #       "Protected zone"
  #     end
  #   end
  #
  # @example Using user data
  #
  #   class AuthUserDataApp
  #     include Roy
  #     roy use: [:basic_auth],
  #         auth: {
  #           realm: "My Realm",
  #           logic: ->(override, u, p) {
  #             override || (%w(admin foobar) == [u, p])
  #           }
  #         }
  #
  #     def get(path)
  #       roy.protected!(path =~ /private/)
  #       "Protected if path contains private"
  #     end
  #   end
  module BasicAuth
    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods

      # Protect all subsequent code using HTTP Basic Authentication.
      #
      # @param data user data to pass to #authorized?
      def protected!(data=nil)
        unless authorized?(data)
          realm = conf.auth && conf.auth[:realm] || 'Realm'
          response['WWW-Authenticate'] = %(Basic realm="#{realm}")
          halt 401
        end
      end

      # Runs the authentication logic against the user and passord given in the
      # request, using custom additional data.
      #
      # @param data user data to pass to the authentication logic
      def authorized?(data=nil)
        auth = Rack::Auth::Basic::Request.new(request.env)

        auth.provided? && auth.basic? && auth.credentials &&
          (conf.auth[:logic] || ->(data, u, p) {
            %w(admin password) == [u, p]
           }).(data, *auth.credentials)
      end
    end
  end
end

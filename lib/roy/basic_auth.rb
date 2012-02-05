module Roy
  module BasicAuth
    def self.setup(roy)
      roy.send(:extend, InstanceMethods)
    end

    module InstanceMethods
      def protected!(data=nil)
        unless authorized?(data)
          realm = conf.auth && conf.auth[:realm] || 'Realm'
          response['WWW-Authenticate'] = %(Basic realm="#{realm}")
          halt 401
        end
      end

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

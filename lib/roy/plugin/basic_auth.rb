module Roy
  module Plugin
    module BasicAuth
      def protected!
        unless authorized?
          realm = roy.conf.auth && roy.conf.auth[:realm] || 'Realm'
          roy.response['WWW-Authenticate'] = %(Basic realm="#{realm}")
          halt 401
        end
      end

      def authorized?
        @auth ||=  Rack::Auth::Basic::Request.new(roy.request.env)
        (roy.conf.auth ||= {})[:credentials] ||= {'admin' => 'password'}

        @auth.provided? && @auth.basic? && @auth.credentials &&
          roy.conf.auth[:credentials].any? do |user, password|
            [user, password] == @auth.credentials
          end
      end
    end
  end
end

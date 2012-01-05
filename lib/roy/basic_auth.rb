module Roy
  module BasicAuth
    def protected!(data=nil)
      unless authorized?(data)
        realm = roy.conf.auth && roy.conf.auth[:realm] || 'Realm'
        roy.response['WWW-Authenticate'] = %(Basic realm="#{realm}")
        halt 401
      end
    end

    def authorized?(data=nil)
      auth = Rack::Auth::Basic::Request.new(roy.request.env)

      auth.provided? && auth.basic? && auth.credentials &&
        (roy.conf.auth[:logic] || ->(data, u, p) {
          %w(admin password) == [u, p]
         }).(data, *auth.credentials)
    end
  end
end

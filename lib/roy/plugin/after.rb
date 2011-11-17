module Roy
  module Plugin
    module After
      def call(env)
        status, header, body = super
        resp = Rack::Response.new(body, status, header)
        (roy.conf.after || lambda {|x| x }).(resp)
        resp.finish
      end
    end
  end
end

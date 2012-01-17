module Roy
  class Context
    attr_reader :app, :conf, :env, :request, :response, :headers, :params

    def initialize(app)
      @app  = app
      @conf = app.class.conf

      app.class.ancestors.reverse.each do |mod|
        mod.setup(self) if mod.respond_to?(:setup)
      end
    end

    def prepare!(env)
      @env      = env
      @request  = Rack::Request.new(env)
      @response = Rack::Response.new
      @headers  = @response.header
      @params   = @request.GET.merge(@request.POST)
      @params.default_proc = proc do |hash, key|
        hash[key.to_s] if Symbol === key
      end
    end
  end
end

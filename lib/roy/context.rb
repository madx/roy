module Roy
  # Application context for Roy applications.
  #
  # Everything must be namespaced in this context to avoid any clashes and to
  # make the code cleaner.
  class Context
    # Returns the current application
    attr_reader :app

    # Returns the application's configuration
    attr_reader :conf

    # Returns the environment passed to #call
    attr_reader :env

    # Returns the current request
    attr_reader :request

    # Returns the current response
    attr_reader :response

    # Returns the current response's headers
    attr_reader :headers

    # Returns the current request's params
    attr_reader :params

    # Creates a new Context object.
    #
    # @param app the context's application
    def initialize(app)
      @app  = app
      @conf = app.class.conf

      app.class.ancestors.reverse.each do |mod|
        mod.setup(self) if mod.respond_to?(:setup)
      end
    end

    # Initializes the attributes based on an environment.
    #
    # @param env the environment to use
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

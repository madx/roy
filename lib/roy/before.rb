module Roy
  module Before
    def call(env)
      (roy.conf.before || lambda {|x| x }).(env)
      super
    end
  end
end

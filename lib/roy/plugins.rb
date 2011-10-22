module Roy
  def self.Plugins(*names)
    return Module.new.tap do |mod|
      names.each do |name|
        mod.send(:include, name)
      end
    end
  end
end


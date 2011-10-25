module Roy
  def self.Plugins(*names)
    return Module.new.tap do |mod|
      names.each do |name|
        if name.is_a?(Symbol)
          require "roy/#{name}"
          name = Roy.const_get("#{name}".capitalize.to_sym)
        end
        mod.send(:include, name)
      end
    end
  end
end


module Roy
  module Plugin; end

  def self.Plugins(*names)
    return Module.new.tap do |mod|
      names.each do |name|
        if name.is_a?(Symbol)
          require "roy/plugin/#{name}"
          name = Roy::Plugin.const_get("#{name}".capitalize.to_sym)
        end
        mod.send(:include, name)
      end
    end
  end
end


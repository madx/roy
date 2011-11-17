module Roy
  module Plugin; end

  def self.Plugins(*names)
    return Module.new.tap do |mod|
      names.each do |name|
        if name.is_a?(Symbol)
          require "roy/plugin/#{name}"
          const = "#{name}".capitalize.gsub(/_(\w)/) {|m| m[1].upcase }.to_sym
          name = Roy::Plugin.const_get(const)
        end
        mod.send(:include, name)
      end
    end
  end
end


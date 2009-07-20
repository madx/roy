require File.join(File.dirname(__FILE__), '..', 'rackable')

class RestArray
  include Rackable

  def initialize
    @array = ['Hello, world!']
  end

  def get()
    @array.inspect
  end

  def put()
    if rack.data[:item]
      item = case input = rack.data[:item].strip
        when /^(\d+)$/: input.to_i
        else input
      end
      (@array << item).inspect
    else
      http_error 400
    end
  end

  def delete(index=0)
    @array.tap { |a| a.delete_at(index) }.inspect
  end

end

run RestArray.new

require File.join(File.dirname(__FILE__), '..', 'rackable')

class RestString
  include Rackable

  def initialize
    @string = "Hello, world!"
  end

  def get()
    @string
  end

  def put()
    if rack.data[:body]
      @string << rack.data[:body]
    else
      http_error 400
    end
  end

  def delete()
    @string = ""
  end

end

run RestString.new

Roy
===

Roy is a tiny module that aims to make any Ruby object Rack-friendly and provite
it with a REST-like interface.

Roy tries to be as less invasive as possible. In provides your objects with a
`#call` method that takes a Rack environment and dispatchs to a regular method
named after the HTTP method you want to catch.

## Tests

You can run the tests by running `rake test`. They are written with Minitest.

## Example

``` ruby
class MessageQueue
  include Roy

  roy allow: [:get, :post, :delete]

  def initialize
    @stack = []
  end

  def get
    @stack.inspect
  end

  def post
    halt 403 unless roy.params[:item]
    @stack << roy.params[:item].strip
    get
  end

  def delete
    @stack.shift.inspect
  end
end
```

## Docs

### Configuration

The `roy` class method is mainly used to define access control and method
prefix. You can also define your own options.  The following example should be
self-explanatory enough:

``` ruby
class Example
  include Roy
  roy allow: [:get], prefix: :http_, foo: "bar"

  def http_get(*args)
    "foo is #{roy.conf.bar}"
  end
end
```
### Environement

Inside your handler methods, you have access to a `roy` readable attribute which
is a struct containing the following fields:

* `env`: the Rack environment
* `response`: a `Rack::Response` object that will be returned by `call`
* `request`: a `Rack::Request` build from the environment
* `header`: a hash of headers that is part of `response`
* `params`: parameters extracted from the query string and the request body
* `conf`: the configuration set via `::roy`

The keys for `params` can be accessed either via a `String` or a `Symbol`

### Control flow

Your handler methods are run inside a `catch` block which will catch the `:halt`
symbol. You can then use `throw` to abort a method but you must return an array
composed of a status code and a message.

Roy provides a `halt` method that takes a status code and an optional message.
If there is no message it uses the default message from
`Rack::Utils::HTTP_STATUS_CODES`

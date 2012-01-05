require_relative '../helper'

Templates = {
  simple: %q(<%= "Hello world!" %>),
  locals: %q(<%= "Hello #{person}" %>),
  scope:  %q(<%= roy.conf.inspect %>),
  yield:  %q(<%= yield %>)
}

class RenderTestObject
  include Roy

  roy allow: [:get],
      views: 'test/views',
      use: [:render]

  def get(path)
    case path
    when '/template'
      render :erb, :test
    when '/template_layout'
      render :erb, :layout do
        render :erb, :test
      end
    when '/inline'
      render :erb, Templates[:simple]
    when '/locals'
      render :erb, Templates[:locals], person: 'Bob'
    when '/scope'
      render :erb, Templates[:scope]
    when '/yield'
      render :erb, Templates[:yield] do
        render :erb, Templates[:simple]
      end
    end
  end
end

class RenderTest < MiniTest::Unit::TestCase
  include Rack::Test::Methods

  def app
    RenderTestObject.new
  end

  def inline(tid, params={}, &block)
    Tilt[:erb].new { Templates[tid] }.render(app, params, &block)
  end

  def test_render_file_template
    get '/template'
    assert_equal inline(:simple), last_response.body
  end

  def test_render_file_layout
    get '/template_layout'
    assert_equal inline(:simple), last_response.body
  end

  def test_render_inline_template
    get '/inline'
    ok!
    assert_equal inline(:simple), last_response.body
  end

  def test_render_inline_template_with_locals
    get '/locals'
    ok!
    assert_equal inline(:locals, person: 'Bob'), last_response.body
  end

  def test_render_inline_scope
    get '/scope'
    ok!
    assert_equal inline(:scope), last_response.body
  end

  def test_render_with_block
    get '/yield'
    ok!
    assert_equal inline(:simple), last_response.body
  end

end

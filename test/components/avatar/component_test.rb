# frozen_string_literal: true

require 'test_helper'

class Avatar::ComponentTest < ViewComponent::TestCase
  def setup
    ActiveStorage::Current.url_options = { host: 'test.host' }
    user = create(:user, :gaurav)
    @component = Avatar::Component.new(
      avatar: user.avatar,
      fallback: user.name.initials,
      gravatar: user.gravatar_url
    )
  end

  def test_component_renders_something_useful
    assert_equal(
      %(
        <div class="avatar"> <lazy-image class="w-8 h-8 rounded-full" rounded src="//secure.gravatar.com/avatar/d79899c0fc43470b3a83e2928034f2dc?d=identicon&amp;s=32" title="GT"> </lazy-image> </div>
      ).squish,
      render_inline(@component).to_html.squish
    )
  end
end

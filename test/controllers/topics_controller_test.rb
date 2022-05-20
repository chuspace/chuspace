# frozen_string_literal: true

require 'test_helper'

class TopicsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @topic = create(:topic)
  end

  def test_topics_show
    get topic_path(@topic)

    assert_equal 200, status
    assert_template 'topics/show'
  end
end

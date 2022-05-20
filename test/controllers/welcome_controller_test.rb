# frozen_string_literal: true

require 'test_helper'

class WelcomeControllerTest < ActionDispatch::IntegrationTest
  def test_welcome
    get '/'
    assert_equal 200, status
    assert_template 'welcome/index'
  end
end

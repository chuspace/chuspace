# frozen_string_literal: true

require 'test_helper'

class SignupsControllerTest < ActionDispatch::IntegrationTest
  def test_signups_index
    get signups_path

    assert_equal 200, status
    assert_template 'signups/index'
  end

  def test_signups_email
    get email_signups_path

    assert_equal 200, status
    assert_template 'signups/email'
  end
end

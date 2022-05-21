# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user, :gaurav)
  end

  def test_sessions_index
    get sessions_path

    assert_equal 200, status
    assert_template 'sessions/index'
  end

  def test_sessions_email
    get email_sessions_path

    assert_equal 200, status
    assert_template 'sessions/email'

    perform_enqueued_jobs do
      post sessions_path, params: { user: { email: @user.email } }
      follow_redirect!
      assert_equal 200, status

      assert_equal 'Please check your email', flash[:notice]
      assert_emails 1

      mail = ActionMailer::Base.deliveries.last
      assert_equal @user.email, mail['to'].to_s
    end
  end
end

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

    # Successful signup
    perform_enqueued_jobs do
      post signups_path, params: { user: { email: 'gaurav+signup@chuspace.com', name: 'Gaurav Tiwari', username: 'gauravtiwari' } }
      follow_redirect!
      assert_equal 200, status

      assert_equal 'Thanks for signing up. Please check your email', flash[:notice]
      assert_emails 1
      assert_equal 'gaurav+signup@chuspace.com', User.last.email

      mail = ActionMailer::Base.deliveries.last
      assert_equal 'gaurav+signup@chuspace.com', mail['to'].to_s
    end

    # Unsuccessful signup
    post signups_path, params: { user: { email: 'gaurav+signup2@chuspace.com', name: 'Gaurav Tiwari', username: 'gauravtiwari' } }
    assert_equal 302, status
    refute 'gaurav+signup2@chuspace.com' == User.last.email
  end
end

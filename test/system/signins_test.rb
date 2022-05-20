# frozen_string_literal: true

require 'application_system_test_case'

class SigninsTest < ApplicationSystemTestCase
  test 'Creating signin' do
    visit email_sessions_url
    user = create(:user, :gaurav)
    assert_selector 'h2', text: 'Sign in'
    assert_selector 'button', text: 'Sign in'

    click_button 'Sign in'
    assert_text 'No email identity found for this email'

    fill_in 'user_email', with: "gaurav-#{rand(0..100)}"
    click_button 'Sign in'
    assert_text 'No email identity found for this email'

    fill_in 'user_email', with: user.email

    perform_enqueued_jobs do
      assert_emails 1
      click_button 'Sign in'
      sleep 1

      puts ActionMailer::Base.deliveries.last

      mail = ActionMailer::Base.deliveries.last

      assert_equal user.email, mail['to'].to_s
      assert_equal "Sign in to Chuspace, #{user.name}", mail.subject
    end
  end
end

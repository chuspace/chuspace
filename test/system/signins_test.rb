# frozen_string_literal: true

require 'application_system_test_case'

class SigninsTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  def setup
    @email = "gaurav-#{Time.now.to_i}@chuspace.com"
    @user = User.create!(name: 'Gaurav Tiwari', email: @email, username: "gaurav-#{Time.now.to_i}")
  end

  test 'Creating signin' do
    visit email_sessions_url
    assert_selector 'h3', text: 'Sign in'
    assert_selector 'button', text: 'Sign in'

    click_button 'Sign in'
    assert_text "We couldn't find that email"

    fill_in 'signin_email', with: "gaurav-#{rand(0..100)}"
    click_button 'Sign in'
    assert_text "We couldn't find that email. Perhaps you mispelled it?"

    fill_in 'signin_email', with: @email

    perform_enqueued_jobs do
      click_button 'Sign in'
      sleep 1

      user = User.find_by_email @email
      mail = ActionMailer::Base.deliveries.last

      assert_equal user.email, mail['to'].to_s
      assert_equal "Log in to Chuspace, #{user.name}", mail.subject
    end
  end
end

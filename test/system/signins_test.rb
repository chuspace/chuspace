# frozen_string_literal: true

require 'application_system_test_case'

class SigninsTest < ApplicationSystemTestCase
  def setup
    @user     = create(:user, :gaurav)
    @identity = create(:identity, provider: :email, user: @user, uid: @user.email)
  end

  test 'Sign in' do
    visit email_sessions_url

    assert_selector 'h2', text: 'Sign in'
    assert_selector 'button', text: 'Sign in'

    click_button 'Sign in'
    assert_text 'No email identity found for this email'

    fill_in 'user_email', with: "gaurav-#{rand(0..100)}"
    click_button 'Sign in'
    assert_text 'No email identity found for this email'

    fill_in 'user_email', with: @user.email

    perform_enqueued_jobs do
      click_button 'Sign in'
      sleep 1

      assert_emails 1
      mail = ActionMailer::Base.deliveries.last

      assert_equal @user.email, mail['to'].to_s
      assert_equal "Sign in to Chuspace, #{@user.name}", mail.subject
    end
  end

  test 'Sign out' do
    visit magic_logins_url(token: @identity.magic_auth_token)
    assert_text 'No published posts'
    visit root_url
    find('#header-user-dropdown', visible: :all).click
    assert_text 'Sign out'
    click_button 'Sign out'
    assert_text 'Get started'
  end
end

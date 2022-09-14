# frozen_string_literal: true

require 'application_system_test_case'
require_relative '../support/test_session_helper.rb'

class HomeText < ApplicationSystemTestCase
  include TestSessionHelper

  def setup
    @user     = create(:user, :gaurav)
    @identity = @user.identities.email.first
  end

  test 'Public home' do
    visit root_path

    assert_selector 'h5', text: 'Posts'
    assert_selector 'h5', text: 'Welcome to Chuspace'
  end

  test 'Authenticated home' do
    visit magic_logins_url(token: @identity.magic_auth_token)
    visit root_path
    assert_selector 'h5', text: 'Publications'
    find('#header-user-dropdown', visible: :all).click
    assert_selector '#signed_in', text: "Signed in as #{@user.username}", visible: :all
  end
end

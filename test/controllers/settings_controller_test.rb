# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class SettingsControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def test_public_user_settings_show
    get setting_path(id: UserSetting::DEFAULT_PAGE)
    assert_equal 302, status
    follow_redirect!
    assert_template 'sessions/index'
  end

  def test_private_user_settings_show
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, :personal, owner: user, git_provider: git_provider)

    signin(identity: identity)

    get setting_path(id: UserSetting::DEFAULT_PAGE)
    assert_equal 200, status
    assert_template 'settings/show'
    assert_template 'settings/_profile'

    get publication_setting_path(publication, id: UserSetting::DEFAULT_PAGE)
    assert_template 'publications/settings/show'
    assert_template 'publications/settings/_profile'

    assert_raise(ActiveRecord::RecordNotFound) { get setting_path(id: 'foo') }
  end

  def test_private_user_settings_update
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, :personal, owner: user, git_provider: git_provider)

    signin(identity: identity)

    patch setting_path(id: UserSetting::DEFAULT_PAGE), params: { user: { name: 'John Doe' } }
    follow_redirect!
    assert_equal 'John Doe', user.reload.name
  end
end

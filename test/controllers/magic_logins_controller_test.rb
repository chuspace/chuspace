# frozen_string_literal: true

require 'test_helper'

class MagicLoginsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user       = create(:user, :gaurav)
    @identity   = @user.identities.email.first
    @auth_token = @identity.magic_auth_token
  end

  def test_magic_login
    get magic_logins_path, params: { token: @auth_token }
    follow_redirect!
    assert_equal 200, status
    assert_equal 'Successfully signed in', flash[:notice]

    # Retry login
    get magic_logins_path, params: { token: @auth_token }
    assert_equal 'Already signed in', flash[:notice]
  end

  def test_expired_magic_login
    @identity.regenerate_magic_auth_token

    get magic_logins_path, params: { token: @auth_token }
    follow_redirect!
    assert_equal 200, status
    assert_equal 'Your magic auth token is expired', flash[:notice]
  end
end

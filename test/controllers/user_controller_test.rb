# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class UserControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def setup
    @user     = create(:user, :gaurav)
    @identity = create(:identity, :email, user: @user)
  end

  def test_public_user_show
    get "/#{@user.username}"

    assert_equal 200, status
    assert_template 'users/show'
  end

  def test_public_user_publications
    get "/#{@user.username}/publications"

    assert_equal 200, status
    assert_template 'users/publications/index'
  end

  def test_public_user_posts
    get "/#{@user.username}/posts"

    assert_equal 200, status
    assert_template 'users/posts/index'
  end

  def test_private_user_drafts
    get "/#{@user.username}/drafts"

    assert_equal 302, status
    follow_redirect!
    assert_equal 200, status
    assert_equal '/login', path
    assert_template 'sessions/index'

    signin(identity: @identity)
    get "/#{@user.username}/drafts"
    assert_equal 200, status
  end

  def test_private_user_settings
    get '/settings'

    assert_equal 302, status
    follow_redirect!
    assert_equal 200, status
    assert_equal '/login', path
    assert_template 'sessions/index'

    signin(identity: @identity)
    get "/#{@user.username}/drafts"
    assert_equal 200, status
  end
end

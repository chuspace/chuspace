# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class ConnectPublicationsControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def setup
    @user     = create(:user, :gaurav)
    @identity = @user.identities.email.first
  end

  def test_public_connect_home
    get connect_root_path
    assert_equal 302, status
    assert_equal 'You need to sign in', flash[:notice]
  end

  def test_private_connect_home
    signin(identity: @identity)

    get connect_root_path
    assert_equal 200, status
    assert_template 'connect/home/index'
  end
end

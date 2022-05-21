# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class ConnectPersonalPublicationsControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def setup
    @user     = create(:user, :gaurav)
    @identity = @user.identities.email.first
  end

  def test_private_connect_personal_publication
    signin(identity: @identity)

    get connect_personal_publications_path
    assert_equal 200, status
    assert_template 'connect/personal_publications/index'
  end

  def test_private_connect_other_publication
    signin(identity: @identity)

    get connect_other_publications_path
    assert_equal 200, status
    assert_template 'connect/other_publications/index'
  end
end

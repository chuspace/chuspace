# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def setup
    @user     = create(:user, :gaurav)
    @identity = @user.identities.email.first
  end

  def test_authenticated_home
    signin(identity: @identity)

    get '/'
    assert_equal 200, status
    assert_template 'home/index'
  end
end

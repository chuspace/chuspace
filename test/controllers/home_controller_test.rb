# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def test_authenticated_home
    signin(identity: create(:identity, :email))

    get '/'
    assert_equal 200, status
    assert_template 'home/index'
  end
end

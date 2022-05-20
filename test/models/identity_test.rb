# frozen_string_literal: true

require 'test_helper'

class IdentityTest < ActiveSupport::TestCase
  def setup
    @identity = build(:identity, :email)
  end

  test 'sends welcome email' do
    assert @identity.valid?
    @identity.save

    travel_to Time.current + 29.minutes do
      assert @identity.magic_auth_token_valid?
    end

    travel_to Time.current + 31.minutes do
      refute @identity.magic_auth_token_valid?
    end
  end
end

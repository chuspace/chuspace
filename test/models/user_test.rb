# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @invalid_user = User.new
    @valid_user = build(:user, :gaurav)
  end

  test 'user without valid attributes' do
    @invalid_user = User.new
    refute @invalid_user.valid?
    assert_equal 'A valid email is required and Email is invalid or already taken',
                 @invalid_user.errors.messages_for(:email).to_sentence
  end

  test 'user with valid attributes' do
    assert @valid_user.valid?

    assert_equal 'Gaurav', @valid_user.name.first
    assert_equal 'GT', @valid_user.name.initials
    assert_equal 'gaurav', @valid_user.username
    assert_equal 'gaurav@chuspace.com', @valid_user.email
  end

  test 'seeds git providers after create' do
    assert @valid_user.valid?
    assert_enqueued_jobs 0

    perform_enqueued_jobs do
      assert @valid_user.save
      assert_not_empty @valid_user.git_providers
      assert_equal 3, @valid_user.git_providers.count
      assert_equal @valid_user.git_providers.pluck(:name), %w[github gitlab gitea]
    end
  end
end

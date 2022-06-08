# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class InvitesControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def setup
    @user         = create(:user, :gaurav)
    @identity     = create(:identity, :email, user: @user)
    @git_provider = create(:git_provider, user: @user)
    @publication  = create(:publication, owner: @user, git_provider: @git_provider)
  end

  def test_invites_index
    get publication_people_path(@publication)
    assert_equal 302, status

    signin(identity: @identity)

    get publication_people_path(@publication)
    assert_equal 200, status
    assert_template 'publications/people/index'
  end

  def test_invites_create
    signin(identity: @identity)

    perform_enqueued_jobs do
      post publication_invites_path(@publication, params: { invite: { identifier: 'john@doe.com', role: :editor } })
      follow_redirect!
      assert_equal 200, status

      assert_equal 'Invite sent successfully!', flash[:notice]
      assert_emails 1
      assert_equal 'editor', Invite.last.role
      assert_equal 'pending', Invite.last.status
    end

    post publication_invites_path(@publication, params: { invite: { identifier: 'foo@doe.com', role: :foo } })
    follow_redirect!
    assert_equal 200, status
    assert_equal 'Invite sent successfully!', flash[:notice]
    assert_equal 'writer', Invite.last.role
  end

  def test_invites_resend
    signin(identity: @identity)
    @invite = create(:invite, publication: @publication, sender: @user)

    perform_enqueued_jobs do
      patch resend_publication_invite_path(@publication, @invite)
      follow_redirect!
      assert_equal 200, status

      assert_equal 'Invite sent successfully!', flash[:notice]
      assert_emails 1
    end
  end

  def test_invites_delete
    signin(identity: @identity)
    @invite = create(:invite, publication: @publication, sender: @user)

    delete publication_invite_path(@publication, @invite)
    follow_redirect!
    assert_equal 200, status
    assert_equal 'Invite deleted!', flash[:notice]
  end

  def test_invites_accept
    @invite = create(:invite, identifier: 'someone@chuspace.com', publication: @publication, sender: @user)

    get accept_publication_invites_path(@publication, params: { invite_token: @invite.code })
    assert_equal 302, status
    follow_redirect!

    assert_equal 'Please signup to accept invite!', flash[:notice]
    assert_template 'signups/email'

    @invite_user = create(:user, email: 'someone@chuspace.com', username: 'someone')

    get accept_publication_invites_path(@publication, params: { invite_token: @invite.code })
    assert_equal 302, status
    follow_redirect!

    assert_equal "Successfully joined #{@publication.name} publication as writer!", flash[:notice]
    assert_template 'publications/people/index'
  end
end

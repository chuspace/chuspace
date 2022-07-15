# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class PublishingControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def test_publish
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, owner: user, git_provider: git_provider)
    draft        ||= publication.repository.drafts.first

    post publication_publish_draft_path(publication, draft), params: { publishing: { description: 'Added a new version' } }
    assert_equal 302, status
    follow_redirect!
    assert_template 'sessions/index'

    signin(identity: identity)

    # First publish
    post publication_publish_draft_path(publication, draft), params: { publishing: { description: 'Added a new version' } }
    follow_redirect!
    assert_equal 200, status
    assert_equal 'Successfully published!', flash[:notice]
    assert_equal draft.path, Post.last.blob_path

    # Subsequent publish should raise
    assert_raise(ActiveRecord::RecordNotFound) { post publication_publish_draft_path(publication, draft), params: { publishing: { description: 'Added a new version' } } }

    # Republishing should not raise
    assert_nothing_raised { post publication_publish_draft_path(publication, draft, republish: true), params: { publishing: { description: 'Republish' } } }
  end
end

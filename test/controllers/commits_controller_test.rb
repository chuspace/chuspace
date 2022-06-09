# frozen_string_literal: true

require 'test_helper'
require_relative '../support/test_session_helper.rb'

class CommitsControllerTest < ActionDispatch::IntegrationTest
  include TestSessionHelper

  def test_new_commit
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, owner: user, git_provider: git_provider)
    draft        ||= publication.repository.draft(path: '_posts/2021-09-26-welcome-to-jekyll.markdown')

    get publication_new_commit_draft_path(publication, draft)
    assert_equal 302, status
    follow_redirect!
    assert_template 'sessions/index'

    signin(identity: identity)

    assert draft.id != nil
    assert draft.stale.value == nil
    assert draft.local_content.value == nil

    assert_authorized_to(:edit?, draft, with: DraftPolicy) do
      patch publication_autosave_draft_path(publication, draft), params: { draft: { content: 'foo', stale: true } }
      assert_equal 302, status
    end

    assert_authorized_to(:commit?, draft, with: DraftPolicy) do
      get publication_new_commit_draft_path(publication, draft)
      assert_equal 200, status
      assert_template 'publications/drafts/commits/new'
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class PublicationsControllerTest < ActionDispatch::IntegrationTest
  def test_public_publications_show
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, owner: user, git_provider: git_provider)

    get publication_path(publication)
    assert_equal 200, status
    assert_template 'publications/show'

    # Personal publication
    personal_publication  = create(:publication, :personal, owner: user, git_provider: git_provider)

    get publication_path(personal_publication)
    assert_equal 200, status
    assert_template 'users/show'
  end
end

# frozen_string_literal: true

require 'test_helper'

class PostsControllerTest < ActionDispatch::IntegrationTest
  def test_public_posts_show
    user         = create(:user, :gaurav)
    identity     = create(:identity, :email, user: user)
    git_provider = create(:git_provider, user: user)
    publication  = create(:publication, owner: user, git_provider: git_provider)
    post         = create(:post, publication: publication, author: user)

    get publication_post_path(publication, post)

    assert_equal 200, status
    assert_template 'posts/show'
  end
end

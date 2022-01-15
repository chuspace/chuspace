# frozen_string_literal: true

module PostHelper
  def edit_or_show_post_path(post:)
    if post.published?
      user_publication_post_path(post.publication.owner, post.publication, post.editions.current)
    else
      edit_user_publication_post_path(post.publication.owner, post.publication, post.revisions.current)
    end
  end
end

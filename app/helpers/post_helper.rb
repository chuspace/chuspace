module PostHelper
  def edit_or_show_post_path(post:)
    if post.published?
      user_blog_post_path(post.blog.owner, post.blog, post.editions.current)
    else
      edit_user_blog_post_path(post.blog.owner, post.blog, post.revisions.current)
    end
  end
end

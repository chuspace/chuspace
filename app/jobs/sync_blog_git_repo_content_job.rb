class SyncBlogGitRepoContentJob < ApplicationJob
  queue_as :default

  def perform(blog)
    blog.git_blobs.each do |blob|
      Article.create_from_git_blob(blob: blob, blog: blog, author: blog.user)
    end
  end
end

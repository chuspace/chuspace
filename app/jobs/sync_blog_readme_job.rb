class SyncBlogReadmeJob < ApplicationJob
  queue_as :default

  def perform(blog)
    content = Base64.decode64(blog.readme_blob&.content)
    blog.update(readme: content) if content
  end
end

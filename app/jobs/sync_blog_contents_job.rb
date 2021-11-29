# frozen_string_literal: true

class SyncBlogContentsJob < ApplicationJob
  queue_as :default

  def perform(blog:)
    Blog.transaction do
      blog.update!(readme: blog.repository.readme)

      Post.transaction do
        blog.repository.post_blobs.each do |git_blob|
          blog.posts.create!(blob_path: git_blob.path)
        end
      end
    end
  end
end

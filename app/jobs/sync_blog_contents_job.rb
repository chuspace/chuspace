# frozen_string_literal: true

class SyncBlogContentsJob < ApplicationJob
  queue_as :default

  def perform(blog:)
    Draft.transaction do
      blog.repository_blobs.each do |git_blob|
        blog.drafts.create!(blob_path: git_blob.path)
      end
    end
  end
end

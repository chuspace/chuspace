# frozen_string_literal: true

class InstallRepositoryWebhooksJob < ApplicationJob
  queue_as :default

  def perform(blog:)
    Blog.transaction do
      webhook = blog.storage.adapter.create_repository_webhook(fullname: blog.repo_fullname)
      blog.update!(repo_webhook_id: webhook.id)
    end
  end
end

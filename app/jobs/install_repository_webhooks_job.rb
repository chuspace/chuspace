# frozen_string_literal: true

class InstallRepositoryWebhooksJob < ApplicationJob
  queue_as :default

  def perform(publication:)
    Blog.transaction do
      webhook = publication.git_provider.adapter.create_repository_webhook(fullname: publication.repo_fullname)
      publication.repo.webhook_id = webhook.id
      publication.save!
    end
  end
end

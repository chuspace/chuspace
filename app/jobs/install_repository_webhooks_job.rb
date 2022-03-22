# frozen_string_literal: true

class InstallRepositoryWebhooksJob < ApplicationJob
  queue_as :default

  def perform(publication:)
    Publication.transaction do
      webhook = publication.git_provider_adapter.create_repository_webhook
      publication.repo.webhook_id = webhook.id
      publication.save!
    end
  end
end

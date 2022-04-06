# frozen_string_literal: true

class AddRepositoryWebhooksJob < ApplicationJob
  def perform(repository:)
    Repository.transaction do
      if repository.webhook_id.blank?
        webhook = repository.git_provider_adapter.create_repository_webhook
        repository.update(webhook_id: webhook.id) if webhook
      end
    end
  end
end

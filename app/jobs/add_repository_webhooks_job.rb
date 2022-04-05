# frozen_string_literal: true

class AddRepositoryWebhooksJob < ApplicationJob
  def perform(repository:)
    Repository.transaction do
      if repository.webhook_id.blank?
        repository.update!(webhook_id: repository.source_api_adapter.create_repository_webhook.id)
      end
    end
  end
end

# frozen_string_literal: true

class RemoveRepositoryWebhookJob < ApplicationJob
  def perform(repository:)
    repository.remove_git_repository_hook if repository.webhook_id
  end
end

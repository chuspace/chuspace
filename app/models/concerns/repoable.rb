# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    after_destroy        :uninstall_repository_webhooks
    after_create_commit  :install_repository_webhooks
    after_create_commit  -> { AddRepositoryConfigJob.perform_later(repository: self) }
    after_destroy_commit -> { RemoveRepositoryConfigJob.perform_later(repository: self) }
  end

  private

  def install_repository_webhooks
    AddRepositoryWebhooksJob.perform_later(repository: self)
  end

  def uninstall_repository_webhooks
    git_provider_adapter.delete_repository_webhook(id: webhook_id)
  end
end

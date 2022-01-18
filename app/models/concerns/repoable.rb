# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    after_destroy        :uninstall_repository_webhooks, unless: -> { git_provider.github? }
    after_create_commit  :install_repository_webhooks, unless: -> { git_provider.github? }
  end

  def assets_folders
    [repo.assets_folder].freeze
  end

  def posts_folders
    [repo.posts_folder, repo.drafts_folder].reject(&:blank?).freeze
  end

  def repo_drafts_or_posts_folder
    repo.drafts_folder.presence || repo.posts_folder.presence
  end

  private

  def install_repository_webhooks
    InstallRepositoryWebhooksJob.perform_later(publication: self)
  end

  def uninstall_repository_webhooks
    git_provider.adapter.delete_repository_webhook(fullname: repo.fullname, id: repo.webhook_id)
  end
end

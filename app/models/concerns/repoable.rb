# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    before_destroy       :uninstall_repository_webhooks
    after_create_commit  :install_repository_webhooks, :sync_repository_content

    validates_presence_of :repo_fullname, :repo_posts_folder, :repo_assets_folder

    enum repo_status: {
      syncing: 'syncing',
      synced: 'synced',
      failed: 'failed'
    }, _suffix: true
  end

  def assets_folders
    [repo_assets_folder].freeze
  end

  def repository
    Repository.new(blog: self, fullname: repo_fullname)
  end

  def posts_folders
    [repo_posts_folder, repo_drafts_folder].reject(&:blank?).freeze
  end

  def repo_drafts_or_posts_folder
    repo_drafts_folder.presence || repo_posts_folder
  end

  private

  def install_repository_webhooks
    InstallRepositoryWebhooksJob.perform_later(blog: self)
  end

  def uninstall_repository_webhooks
    git_provider.adapter.delete_repository_webhook(fullname: repo_fullname, id: repo_webhook_id)
  end

  def sync_repository_content
    SyncRepositoryContentsJob.perform_later(blog: self)
  end
end

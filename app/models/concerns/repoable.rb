# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    after_destroy        :uninstall_repository_webhooks, unless: -> { git_provider.github? }
    after_create_commit  :install_repository_webhooks, unless: -> { git_provider.github? }
    after_create_commit  -> { AddRepositoryConfigJob.perform_later(publication: self) }
    after_destroy_commit -> { RemoveRepositoryConfigJob.perform_later(publication: self) }
  end

  def assets_folders
    [repo.assets_folder].freeze
  end

  def assets(path: assets_folders)
    path = path.is_a?(Array) ? path : [path]
    @assets ||= repository.assets(path)
  end

  def asset(path:)
    @asset ||= repository.asset(path)
  end

  def content_folders
    [repo.posts_folder, repo.drafts_folder].reject(&:blank?).freeze
  end

  def drafts(path: content_folders)
    path = path.is_a?(Array) ? path : [path]

    @drafts ||= Rails.cache.fetch([self, path.join(':')]) do
      repository.drafts(path)
    end
  end

  def draft(path:)
    @draft ||= Rails.cache.fetch([self, path]) do
      repository.draft(path)
    end
  end

  def readme
    @readme ||= Rails.cache.fetch([self, repo.readme_path]) do
      repository.draft(repo.readme_path).content_html
    end
  end

  def repository
    @repository ||= git_provider_adapter.repository&.with_publication(self)
  end

  def git_provider_adapter(ref: 'HEAD')
    @git_provider_adapter ||= git_provider.adapter.apply_repository_scope(repo_fullname: repo.fullname, ref: ref)
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

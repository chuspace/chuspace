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
    repository.assets(path: path)
  end

  def asset(path:)
    repository.asset(path: path)
  end

  def content_folders
    [repo.posts_folder, repo.drafts_folder].reject(&:blank?).freeze
  end

  def drafts_root_path
    @drafts_root_path ||= Pathname.new(repo_drafts_or_posts_folder)
  end

  def draft_path_for(name:)
    drafts_root_path.join(name).to_s
  end

  def drafts(path: content_folders)
    path = path.is_a?(Array) ? path : [path]
    repository.drafts(path: path)
  end

  def draft(path:)
    repository.draft(path: path)
  end

  def readme
    repository.readme
  end

  def repository(ref: 'HEAD')
    @repository ||= git_provider_adapter(ref: ref).repository&.with_publication(self)
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
    git_provider_adapter.delete_repository_webhook(id: repo.webhook_id)
  end
end

# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    before_create :create_and_connect_git_repo, if: -> { storage.chuspace? }
    after_validation :connect_git_repo, if: -> { storage.external? && repo_fullname_changed? }
    after_destroy_commit :delete_repository_hook, :delete_git_repo, if: -> { storage.chuspace? }
    before_create :create_repository_hook
  end

  def repo_folders
    @repo_folders ||= repo_fullname.blank? ? [] : storage.adapter.repository_folders(fullname: repo_fullname)
  end

  def repository
    @repository ||= storage.adapter.repository(fullname: repo_fullname)
  end

  def repo_head_sha
    @repo_head_sha ||= storage.adapter.head_sha(fullname: repo_fullname)
  end

  def commits
    @commits ||= storage.adapter.commits(fullname: repo_fullname)
  end

  private

  def create_and_connect_git_repo
    repository = storage.adapter.create_repository(blog: self)
    self.repo_fullname = repository.fullname
  rescue StandardError
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def connect_git_repo
    repository = storage.adapter.repository(fullname: repo_fullname)
    self.name = repository.name
    self.description = repository.description
    self.repo_fullname = repository.fullname
  end

  def create_repository_hook
    webhook = storage.adapter.create_repository_webhook(fullname: repo_fullname)
    self.repo_webhook_id = webhook.id
  end

  def delete_repository_hook
    storage.adapter.delete_repository_webhook(fullname: repo_fullname, id: repo_webhook_id)
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repo_fullname)
  end
end

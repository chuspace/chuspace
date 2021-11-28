# frozen_string_literal: true

module Repoable
  extend ActiveSupport::Concern

  included do
    before_create        :create_git_repo, if: -> { storage.chuspace? }
    after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }
    after_create_commit  :sync_repository_blobs

    validates_presence_of :repo_articles_folder, :repo_assets_folder, :repo_readme_path
  end

  def repository_blob(path:, ref: nil)
    storage.adapter.blob(fullname: repo_fullname, path: path, ref: ref)
  end

  def repository_blobs
    storage.adapter.blobs(fullname: repo_fullname, folders: content_folders)
  end

  def repository_assets
    storage.adapter.blobs(fullname: repo_fullname, folders: [repo_assets_folder])
  end

  def repository_commits(path: nil)
    storage.adapter.commits(fullname: repo_fullname, path: path)
  end

  def repository_folders
    name.blank? ? [] : storage.adapter.repository_folders(fullname: repo_fullname)
  end

  def repository_readme
    content = storage.adapter.blob(fullname: repo_fullname, path: repo_readme_path).content
    Base64.decode64(content) if content
  end

  def repository
    storage.adapter.repository(fullname: repo_fullname)
  end

  private

  def create_git_repo
    repository = storage.adapter.create_repository(path: template.chuspace_mirror_path, name: permalink, owner: owner.username)
    self.repo_fullname = repository.fullname
  rescue StandardError
    delete_git_repo
  end

  def content_folders
    [repo_articles_folder, repo_drafts_folder].compact.freeze
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def sync_repository_blobs
    SyncBlogContentsJob.perform_later(blog: self)
  end
end

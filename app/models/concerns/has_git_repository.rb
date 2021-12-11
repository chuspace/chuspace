# frozen_string_literal: true

module HasGitRepository
  extend ActiveSupport::Concern

  included do
    before_create        :create_git_repo, if: -> { storage.chuspace? }
    after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }
    after_create_commit  :sync_repository_blobs

    validates_presence_of :repo_posts_folder, :repo_assets_folder, :repo_readme_path
  end

  def repository
    Repository.new(blog: self, fullname: repo_fullname)
  end

  def posts_folders
    [repo_posts_folder, repo_drafts_folder].reject(&:blank?).freeze
  end

  def assets_folders
    [repo_assets_folder].freeze
  end

  private

  def create_git_repo
    repository = storage.adapter.create_repository(path: template.chuspace_mirror_path, name: permalink, owner: owner.username)
    self.repo_fullname = repository.fullname
  rescue StandardError
    delete_git_repo
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def sync_repository_blobs
    SyncBlogContentsJob.perform_later(blog: self)
  end
end

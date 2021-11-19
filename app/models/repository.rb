# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :blog
  delegate :storage, :template, :user, to: :blog
  has_many :blobs, dependent: :delete_all
  validates_presence_of :name, :articles_folder, :assets_folder, :readme_path

  before_create :create_git_repo, if: -> { storage.chuspace? }
  after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }
  after_create_commit :sync_content

  def git
    @git ||= storage.adapter.repository(fullname: name)
  end

  def git_blobs
    storage.adapter.blobs(fullname: name, folders: content_folders)
  end

  def git_commits
    @commits ||= storage.adapter.commits(fullname: name)
  end

  def folders
    @folders ||= name.blank? ? [] : storage.adapter.repository_folders(fullname: name)
  end

  def content_folders
    [articles_folder, drafts_folder, assets_folder].compact.freeze
  end

  private

  def create_git_repo
    storage.adapter.create_repository(path: template.mirror_path, name: blog.name, owner: user.username)
  rescue StandardError
    delete_git_repo
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repository.name)
  end

  def sync_content
    SyncRepositoryContentJob.perform_later(repository: self)
  end
end

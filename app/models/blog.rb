# frozen_string_literal: true

class Blog < ApplicationRecord
  DEFAULT_FRAMEWORK = 'hugo'

  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders]

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :posts_folder, :drafts_folder, :assets_folder

  enum framework: BlogFrameworkConfig.frameworks_enum, _suffix: true
  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create
  before_create :create_repository
  delegate :provider, :provider_user, to: :storage

  def repository
    @repository ||= storage.adapter.repository(id: git_repo_id)
  end

  def repository_folders
    @repository_folders ||= storage.adapter.repository_folders(id: git_repo_id)
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.send(Blog::DEFAULT_FRAMEWORK).slice(:framework, :posts_folder, :drafts_folder, :assets_folder))
    self.visibility ||= :private
  end

  def create_repository
    repository = storage.adapter.create_repository(blog: self)
    self.git_repo_id = repository.id
  end
end

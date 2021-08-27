# frozen_string_literal: true

class Blog < ApplicationRecord
  DEFAULT_FRAMEWORK = 'hugo'

  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_column: :git_repo_name

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :git_repo_name, :posts_folder, :drafts_folder, :assets_folder

  enum framework: BlogFrameworkConfig.frameworks_enum, _suffix: true
  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults
  before_create :create_repository

  def repository
    @repository ||= storage.adapter.repository(id: provider_git_repo_id)
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.send(Blog::DEFAULT_FRAMEWORK).slice(:framework, :posts_folder, :drafts_folder, :assets_folder))
    self.visibility ||= :private
  end

  def create_repository
    repository = storage.adapter.create_repository(
      name: git_repo_name,
      user_id: storage.provider_user_id,
      description: description,
      visibility: visibility,
      template_name: framework
    )

    self.provider_git_repo_id = repository.id
  end
end

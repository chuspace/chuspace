# frozen_string_literal: true

class Blog < ApplicationRecord
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
  before_create :create_repository, unless: :git_repo_id
  after_destroy_commit :delete_repository

  delegate :provider, :provider_user, to: :storage
  delegate :template_name, to: :framework_config

  scope :default, -> { find_by(default: true) }

  def repository
    if git_repo_id.present?
      @repository ||= storage.adapter.repository(id: git_repo_id)
    else
      nil
    end
  end

  def repository_folders
    @repository_folders ||= if git_repo_id.present?
      storage.adapter.repository_folders(id: git_repo_id)
    else
      []
    end
  end

  def framework_config
    @framework_config ||= OpenStruct.new(BlogFrameworkConfig.new.send(framework))
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def create_draft_article(name:, content:)
    path = "#{drafts_folder}/#{name.parameterize}.md"
    storage.adapter.create_blob(repo_id: git_repo_id, path: path, content: content, message: nil)
  end

  def create_article
    path = "#{posts_folder}/#{name.parameterize}.md"
    storage.adapter.create_blob(repo_id: git_repo_id, path: path, content: content, message: nil)
  end

  def article(id:)
    storage.adapter.find_blob(repo_id: git_repo_id, id: id)
  end

  def articles
    storage.adapter.blobs(repo_id: git_repo_id, path: posts_folder)
  end

  def drafts
    storage.adapter.blobs(repo_id: git_repo_id, path: drafts_folder)
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:posts_folder, :drafts_folder, :assets_folder))
    self.visibility ||= :private
  end

  def create_repository
    repository = storage.adapter.create_repository(blog: self)
    self.git_repo_id = repository.id
  end

  def delete_repository
    storage.adapter.delete_repository(id: git_repo_id)
  end
end

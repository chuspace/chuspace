# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_limit: 40, sequence_separator: '--'

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :posts_folder, :drafts_folder, :assets_folder

  attribute :git_repo, GitRepository.to_type
  enum framework: BlogFrameworkConfig.frameworks_enum, _suffix: true

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: :chuspace?
  before_create :create_git_repo, if: -> { git_repo.id.blank? }
  after_destroy_commit :delete_git_repo

  delegate :provider, :chuspace?, to: :storage
  delegate :template_name, to: :framework_config
  scope :default, -> { find_by(default: true) }

  def framework_config
    OpenStruct.new(BlogFrameworkConfig.new.send(framework))
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def create_draft_article(title:, content:)
    path = "#{drafts_folder}/#{title.parameterize}.md"
    storage.adapter.create_blob(blog: blog, path: path, content: content, message: nil)
  end

  def create_article(title:, content:)
    path = "#{posts_folder}/#{title.parameterize}.md"
    storage.adapter.create_blob(blog: blog, path: path, content: content, message: nil)
  end

  def delete_article(id:, path:)
    storage.adapter.delete_blob(blog: blog, path: path, id: id)
  end

  def article(id:)
    Article.from(storage.adapter.find_blob(blog: blog, id: id))
  end

  def articles
    Article.from(storage.adapter.blobs(blog: blog, path: posts_folder))
  end

  def drafts
    Article.from(storage.adapter.blobs(blog: blog, path: drafts_folder))
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:posts_folder, :drafts_folder, :assets_folder))
    self.visibility ||= :private
  end

  def create_git_repo
    self.git_repo = storage.adapter.create_repository(blog: self).attributes
  rescue StandardError
    storage.adapter.delete_repository(blog: self)
  end

  def delete_git_repo
    storage.adapter.delete_repository(blog: self)
  end
end

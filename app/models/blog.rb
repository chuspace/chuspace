# frozen_string_literal: true

class Blog < ApplicationRecord
  include Repoable
  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_limit: 40, sequence_separator: '--'

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :repo_articles_path, :repo_drafts_path, :repo_assets_path
  validates :default, uniqueness: { scope: :user_id, message: :one_default_blog_allowed }
  enum framework: BlogFrameworkConfig.frameworks_enum, _suffix: true

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: -> { storage.chuspace? }
  delegate :template_name, to: :framework_config
  scope :default, -> { find_by(default: true) }

  def framework_config
    OpenStruct.new(BlogFrameworkConfig.new.send(framework))
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def create_draft_article(title:, content:)
    path = "#{repo_drafts_path}/#{title.parameterize}.md"
    storage.adapter.create_blob(blog: blog, path: path, content: content, message: nil)
  end

  def create_article(title:, content:)
    path = "#{repo_articles_path}/#{title.parameterize}.md"
    storage.adapter.create_blob(blog: blog, path: path, content: content, message: nil)
  end

  def delete_article(id:, path:)
    storage.adapter.delete_blob(blog: blog, path: path, id: id)
  end

  def article(id:)
    Article.from(storage.adapter.find_blob(fullname: repo_fullname, id: id))
  end

  def articles
    Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_articles_path))
  end

  def drafts
    Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_drafts_path))
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:repo_articles_path, :repo_drafts_path, :repo_assets_path, :repo_about_path))
    self.visibility ||= :private
  end
end

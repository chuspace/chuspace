# frozen_string_literal: true

class Blog < ApplicationRecord
  include Repoable
  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_limit: 40, sequence_separator: '--'

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :repo_articles_path, :repo_drafts_path, :repo_assets_path
  # validates :default, uniqueness: { scope: :user_id, message: :one_default_blog_allowed }
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

  def article(id:)
    articles.find { |article| article.id == id }
  end

  def draft(id:)
    drafts.find { |draft| draft.id == id }
  end

  def articles
    @articles ||= Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_articles_path), self)
  end

  def drafts
    @drafts ||= Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_drafts_path), self)
  end

  private

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:repo_articles_path, :repo_drafts_path, :repo_assets_path, :repo_about_path))
    self.visibility ||= :private
  end
end

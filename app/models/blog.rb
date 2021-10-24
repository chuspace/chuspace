# frozen_string_literal: true

class Blog < ApplicationRecord
  include Repoable

  belongs_to :user
  belongs_to :storage
  belongs_to :template, optional: true

  validates_presence_of :name, :repo_articles_path, :repo_drafts_path, :repo_assets_path
  validate :one_default_blog_allowed, on: :create

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: -> { storage.chuspace? }
  scope :default, -> { find_by(default: true) }

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

  def one_default_blog_allowed
    errors.add(:default, :one_default_blog_allowed) if default? && user.blogs.default.any?
  end

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:repo_articles_path, :repo_drafts_path, :repo_assets_path, :repo_about_path))
    self.visibility ||= :private
  end
end

# frozen_string_literal: true

class Blog < ApplicationRecord
  include Repoable
  extend FriendlyId
  friendly_id :name, use: :history, slug_column: :permalink

  belongs_to :user
  belongs_to :storage
  belongs_to :template, optional: true, class_name: 'BlogTemplate'

  validates :permalink, uniqueness: { scope: :user_id }
  validates_presence_of :template_id, if: -> { storage.chuspace? }
  validates_presence_of :name, :visibility, :repo_articles_folder, :repo_assets_folder
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

  def asset(path:)
    storage.adapter.blob(fullname: repo_fullname, path: path)
  end

  def articles
    @articles ||= Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_articles_folder), self)
  end

  def drafts
    @drafts ||= Article.from(storage.adapter.blobs(fullname: repo_fullname, path: repo_drafts_folder), self)
  end

  def assets
    @assets ||= storage.adapter.blobs(fullname: repo_fullname, path: repo_assets_folder)
  end

  def readme
    @readme ||= Article.from(storage.adapter.blob(fullname: repo_fullname, path: readme_path), self).content
  end

  private

  def one_default_blog_allowed
    errors.add(:default, :one_default_blog_allowed) if default? && user.blogs.default.any?
  end

  def set_defaults
    self.assign_attributes(template&.blog_attributes) if template
    self.visibility ||= :private
  end

  def should_generate_new_friendly_id?
    permalink.blank? || name_changed?
  end

  def resolve_friendly_id_conflict(candidates)
    self.permalink = normalize_friendly_id(name)
  end
end

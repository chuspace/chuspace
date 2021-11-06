# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  include Repoable, Markdownable, Commitable, MeiliSearch

  friendly_id :name, use: %i[history finders], slug_column: :permalink

  belongs_to :user
  belongs_to :storage
  belongs_to :template, optional: true

  has_many_attached :images
  has_many :articles, dependent: :delete_all
  has_rich_text :readme
  markdownable :readme_content

  validates_presence_of :name, :content_paths, :readme_path
  validate :one_default_blog_allowed, on: :create

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: -> { storage.chuspace? }
  after_create_commit :sync_readme, :sync_git_repo_content

  scope :default, -> { find_by(default: true) }

  meilisearch do
    attribute :name, :description, :visibility
    searchable_attributes %i[name description visibility]
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def readme_blob
    @readme_blob ||= storage.adapter.blob(
      fullname: repo_fullname,
      path: readme_path
    )
  end

  def readme_content
    readme.to_plain_text
  end

  def readme_to_html
    MarkdownRenderer.new.render(markdown_ast)
  end

  def git_blobs
    @git_blobs ||= storage.adapter.blobs(
      fullname: repo_fullname,
      paths: content_paths
    )
  end

  private

  def one_default_blog_allowed
    errors.add(:default, :one_default_blog_allowed) if default? && user.blogs.default.any?
  end

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:content_paths))
    self.visibility ||= :private
  end

  def sync_readme
    SyncBlogReadmeJob.perform_later(self)
  end

  def sync_git_repo_content
    SyncBlogGitRepoContentJob.perform_later(self)
  end
end

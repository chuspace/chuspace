# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  include Repoable, Commitable, MeiliSearch
  friendly_id :name, use: %i[history finders], slug_column: :permalink

  belongs_to :user
  belongs_to :storage
  belongs_to :template, optional: true

  has_many :articles, dependent: :delete_all

  validates_presence_of :name, :repo_articles_folder, :repo_assets_folder, :readme_path
  validate :one_default_blog_allowed, on: :create

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: -> { storage.chuspace? }
  after_create_commit :sync_git_repo_content

  scope :default, -> { find_by(default: true) }

  meilisearch do
    attribute :name, :description, :visibility
    searchable_attributes %i[name description visibility]
  end

  def visibility
    super ? ActiveSupport::StringInquirer.new(super) : nil
  end

  def git_blobs
    storage.adapter.blobs(fullname: repo_fullname, paths: [repo_articles_folder, repo_drafts_folder, repo_assets_folder, readme_path])
  end

  def git_blob(path:)
    Blob.from(storage.adapter.blob(fullname: repo_fullname, path: path), self)
  end

  def readme_blob
    git_blob(path: readme_path)
  end

  def readme_html
    blob_content = readme_blob.content
    markdown_ast = MarkdownParserService.call(blog: self, content: blob_content)
    MarkdownRenderer.new.render(markdown_ast)
  end

  private

  def one_default_blog_allowed
    errors.add(:default, :one_default_blog_allowed) if default? && user.blogs.default.any?
  end

  def set_defaults
    self.assign_attributes(BlogFrameworkConfig.new.send(framework).slice(:repo_articles_folder, :repo_drafts_folder, :repo_assets_folder))
    self.visibility ||= :private
  end

  def sync_git_repo_content
    SyncBlogGitRepoContentJob.perform_later(self)
  end
end

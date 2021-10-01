# frozen_string_literal: true

class Blog < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: %i[slugged history finders], slug_limit: 40, sequence_separator: '--'

  belongs_to :user
  belongs_to :storage
  validates_presence_of :name, :repo_articles_path, :repo_drafts_path, :repo_assets_path
  enum framework: BlogFrameworkConfig.frameworks_enum, _suffix: true

  enum visibility: {
    private: 'private',
    public: 'public',
    internal: 'internal'
  }, _suffix: true

  before_validation :set_defaults, on: :create, if: -> { storage.chuspace? }
  before_create :create_and_connect_git_repo, if: -> { storage.chuspace? && repo_id.blank? }
  after_validation :connect_git_repo, if: -> { storage.external? && repo_fullname.present? }
  after_destroy_commit :delete_git_repo, if: -> { storage.chuspace? }

  delegate :template_name, to: :framework_config
  scope :default, -> { find_by(default: true) }

  def repo_folders
    repo_fullname ? storage.adapter.repository_folders(fullname: repo_fullname) : []
  end

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

  def create_and_connect_git_repo
    repository = storage.adapter.create_repository(blog: self)
    self.attributes = {
      repo_id: repository.id,
      repo_fullname: repository.fullname,
      repo_name: repository.name,
      repo_owner: repository.owner,
      repo_ssh_url: repository.ssh_url,
      repo_html_url: repository.html_url,
      repo_default_branch: repository.default_branch
    }
  rescue StandardError
    storage.adapter.delete_repository(fullname: repo_fullname)
  end

  def connect_git_repo
    self.assign_attributes(storage.adapter.repository(fullname: repo_fullname).to_attrs)
  end

  def delete_git_repo
    storage.adapter.delete_repository(fullname: repo_fullname)
  end
end

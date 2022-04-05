class Repository < ApplicationRecord
  include Mirrorable

  CONFIG_FILE_PATH = 'chuspace.yml'
  CONNECT_MESSAGE = 'Connect chuspace'
  DISCONNECT_MESSAGE = 'Disconnect chuspace'

  belongs_to :publication
  belongs_to :git_provider

  after_initialize :set_defaults
  before_destroy :remove_connection
  after_create_commit :wire_connection

  validates :full_name, :default_ref, :posts_folder, :assets_folder, presence: true
  validates :full_name, uniqueness: true

  delegate :name, :description, :html_url, :owner, :default_branch, to: :git
  delegate :api, :mirror_api, to: :git_provider

  def self.chuspace_yaml_config
    PublicationConfig.new.to_h.deep_stringify_keys.to_yaml
  end

  def assets
    Asset.new(repository: self).all
  end

  def assets_folders
    [assets_folder].freeze
  end

  def config_exists?
    contents.find(CONFIG_FILE_PATH).persisted?
  end

  def commits
    Git::Commit.new(repository: self).all
  end

  def contents
    Git::Blob.new(repository: self).all
  end

  def contents_folders
    [assets_folder, drafts_folder, posts_folder].reject(&:blank?).freeze
  end

  def drafts
    Draft.new(repository: self).all
  end

  def drafts_or_posts_folder
    drafts_folder.presence || posts_folder.presence
  end

  def drafts_folders
    [posts_folder, drafts_folder].reject(&:blank?).freeze
  end

  def endpoint
    "repos/#{full_name}"
  end

  def friendly_full_name
    full_name.tr('/', '-').to_slug.normalize.to_s
  end

  def git
    Git::Repository.for(repository)
  end

  def head_sha
    @head_sha ||= commits.first.sha
  rescue FaradayClient::NotFound
    nil
  end

  def markdown_files
    files.select { |path| MarkdownValidator.valid?(name_or_path: path) }
  end

  def readme
    drafts.find(readme_path)
  end

  def add_git_repository_config
    Git::Blob.new(
      repository: self,
      path: Git::Repository::CONFIG_FILE_PATH,
      content: Base64.encode64(Git::Repository.chuspace_yaml_config)
    ).create(message: Git::Repository::CONNECT_MESSAGE, committer: Git::Committer.chuspace, author: Git::Committer.chuspace)
  end

  def remove_git_repository_config
    blobs
    .find(Git::Repository::CONFIG_FILE_PATH)
    .delete(
      message: DISCONNECT_MESSAGE,
      committer: Git::Committer.chuspace,
      author: Git::Committer.chuspace
    )
  end

  private

  def set_defaults
    self.readme_path = PublicationConfig.new.repo[:readme_path]

    if full_name.present?
      org_name = Rails.application.credentials.chuspace.git_mirror[:org_name]
      self.mirror_full_name = [org_name, friendly_full_name].join('/')
    end
  end

  def wire_connection
    AddRepositoryWebhooksJob.perform_later(repository: self)
    AddRepositoryConfigJob.perform_later(repository: self)
  end

  def remove_connection
    RemoveRepositoryWebhookJob.perform_now(repository: self)
    RemoveRepositoryConfigJob.perform_now(repository: self)
  end
end

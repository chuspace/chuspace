class Repository < ApplicationRecord
  include Repoable

  belongs_to :publication
  belongs_to :git_provider

  validates :full_name, :default_ref, :posts_folder, :assets_folder, presence: true
  validates :full_name, uniqueness: true

  delegate :name, :description, :html_url, :owner, :default_branch, to: :git

  CONFIG_FILE_PATH = 'chuspace.yml'
  CONNECT_MESSAGE = 'Connect chuspace'
  DISCONNECT_MESSAGE = 'Disconnect chuspace'

  def self.chuspace_yaml_config
    PublicationConfig.new.to_h.deep_stringify_keys.to_yaml
  end

  def config_exists?
    git_provider_adapter.blob(path: CONFIG_FILE_PATH).persisted?
  end

  def assets_folders
    [assets_folder].freeze
  end

  def asset(path:)
    blob(path: path)
  end

  def assets(path: assets_folders)
    path = path.is_a?(Array) ? path : [path]
    blobs(paths: path)
  end

  def content_folders
    [posts_folder, drafts_folder].reject(&:blank?).freeze
  end

  def draft(path:)
    blob(path: path)
  end

  def drafts(path: content_folders)
    path = path.is_a?(Array) ? path : [path]
    blobs(paths: path)
  end

  def drafts_or_posts_folder
    drafts_folder.presence || posts_folder.presence
  end

  def friendly_full_name
    full_name.tr('/', '-').to_slug.normalize.to_s
  end

  def files
    git_provider_adapter.repository_files
  end

  def folders
    git_provider_adapter.repository_folders
  end

  def git
    @git ||= git_provider_adapter.repository
  end

  def git_provider_adapter(ref: default_ref)
    @git_provider_adapter ||= git_provider.adapter.apply_repository_scope(repo_fullname: full_name, ref: ref)
  end

  def markdown_files
    files.select { |path| MarkdownValidator.valid?(name_or_path: path) }
  end

  def readme
    blob(path: readme_path)
  end

  def tree(path:)
    git_provider_adapter.tree(path: path)
  end

  def webhooks
    git_provider_adapter.webhooks
  end

  private

  def blobs(paths:)
    Rails.cache.fetch([self, paths.join(':')]) do
      git_provider_adapter.blobs(paths: paths)
        .select { |blob| Git::Blob.valid?(name: blob.name) }
        .map { |blob| blob.decorate(publication: publication) }
    end
  end

  def blob(path:)
    fail ActiveRecord::RecordNotFound, 'not found' unless Git::Blob.valid?(name: path)

    Rails.cache.fetch([self, path]) do
      git_provider_adapter.blob(path: path).decorate(publication: publication)
    end
  end
end

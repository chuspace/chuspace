# frozen_string_literal: true

class Repository < ApplicationRecord
  belongs_to :publication
  belongs_to :git_provider

  validates :full_name, :default_ref, :posts_folder, :assets_folder, :readme_path, presence: true
  validates :full_name, uniqueness: true
  validates :readme_path, markdown: true

  delegate :name, :description, :html_url, :owner, :default_branch, to: :git

  def assets_folders
    [assets_folder].freeze
  end

  def raw(path:)
    pathname = Pathname.new(path)
    pathname = (pathname.absolute? ? pathname.relative_path_from('/') : pathname)
    blob = tree.find { |asset| asset.path == pathname.to_s || asset.path.include?(pathname.cleanpath.to_s) }
    content = git_provider_adapter.asset(sha: blob.sha).content
    Base64.decode64(content)
  end

  def asset(path:)
    fail ActiveRecord::RecordNotFound, 'not found' unless ImageValidator.valid?(name_or_path: path)
    git_provider_adapter.blob(path: path).decorate(publication: publication)
  end

  def assets(path: assets_folders)
    paths = path.is_a?(Array) ? path : [path]

    git_provider_adapter.blobs(paths: paths)
      .select { |blob|  blob.type == 'dir' || (blob&.name && ImageValidator.valid?(name_or_path: blob.name)) }
      .map { |blob| blob.decorate(publication: publication) }
  end

  def content_folders
    [posts_folder, drafts_folder, assets_folder, readme_path].reject(&:blank?).freeze
  end

  def contents
    git_provider_adapter.blobs(paths: content_folders)
      .select { |blob| Git::Blob.valid?(name: blob.name) }
      .map { |blob| blob.decorate(publication: publication) }
  end

  def draft(path:)
    fail ActiveRecord::RecordNotFound, 'not found' unless MarkdownValidator.valid?(name_or_path: path)
    git_provider_adapter.blob(path: path).decorate(publication: publication)
  end

  def draft_at(path:, ref:)
    fail ActiveRecord::RecordNotFound, 'not found' unless MarkdownValidator.valid?(name_or_path: path)
    git_provider_adapter(ref: ref).blob(path: path).decorate(publication: publication)
  end

  def drafts(path: drafts_folders, published: false)
    paths = path.is_a?(Array) ? path : [path]

    drafts = git_provider_adapter.blobs(paths: paths)
      .select { |blob| blob.type == 'dir' || MarkdownValidator.valid?(name_or_path: blob.name) }
      .map { |blob| blob.decorate(publication: publication) }

    if published
      published_draft_paths = publication.posts.pluck(:blob_path)
      drafts = drafts.select { |draft| published_draft_paths.include?(draft.path) }
    end

    drafts
  end

  def drafts_folders
    [drafts_folder.presence, posts_folder.presence].compact
  end

  def drafts_or_posts_folder
    drafts_folder.presence || posts_folder.presence
  end

  def blob_exists?(path:)
    contents.find { |content| content.path == path }&.id&.present?
  end

  def friendly_full_name
    full_name.tr('/', '-').to_slug.normalize.to_s
  end

  def files(ref: default_ref)
    @files ||= git_provider_adapter(ref: ref).repository_files
  end

  def folders(ref: default_ref)
    @folders ||= git_provider_adapter(ref: ref).repository_folders
  end

  def git
    @git ||= git_provider_adapter.repository
  end

  def git_provider_adapter(ref: default_ref)
    git_provider.adapter.apply_repository_scope(repo_fullname: full_name, ref: ref)
  end

  def markdown_files
    files.select { |path| MarkdownValidator.valid?(name_or_path: path) }
  end

  def draft_files
    tree.filter_map do |item|
      next unless draft?(path: item.path) && MarkdownValidator.valid?(name_or_path: item.path)

      item
    end
  end

  def draft?(path:)
    drafts_folder.present? && path.start_with?(drafts_folder) || path.start_with?(posts_folder)
  end

  def readme(ref: default_ref)
    git_provider_adapter(ref: ref).blob(path: readme_path).decorate(publication: publication)
  end

  def tree(ref: default_ref)
    git_provider_adapter(ref: ref).tree
  end

  def webhooks
    git_provider_adapter.webhooks
  end
end

# frozen_string_literal: true

class Repository
  include ActiveModel::API

  attr_accessor :publication, :git_adapter
  validates :publication, presence: true
  delegate :name, :description, :visibility, to: :instance

  def self.for(publication:, ref: 'HEAD')
    git_adapter = publication.git_provider.adapter.apply_repository_scope(repo_fullname: publication.repo.fullname, ref: ref)
    new(publication: publication, git_adapter: git_adapter)
  end

  def assets
    @assets ||= git_adapter.blobs(path: publication.repo.assets_folder)
  end

  def commits(path: nil)
    @commits ||= git_adapter.commits(path: path)
  end

  def commit(sha:)
    @commit ||= git_adapter.commit(sha: sha)
  end

  def draft(path:)
    blob = git_adapter.blob(path: path)
    @draft ||= Draft.for(front_matter_settings: publication.front_matter, blob: blob)
  end

  def drafts(path: nil)
    @drafts ||= git_adapter.blobs(path: path || publication.repo.posts_folder).each do |blob|
      Draft.for(front_matter_settings: publication.front_matter, blob: blob)
    end
  end

  def files
    @files ||= git_adapter.repository_files
  end

  def folders
    @folders ||= git_adapter.repository_folders
  end

  def webhooks
    @webhooks ||= git_adapter.webhooks
  end

  def readme
    content = git_adapter.blob(path: publication.repo.readme_path).content
    @readme ||= Base64.decode64(content).force_encoding('UTF-8') if content
  end

  def readme_html
    MarkdownRenderer.new.render(CommonMarker.render_doc(readme)).html_safe
  end

  def instance
    @instance ||= git_adapter.repository
  end
end

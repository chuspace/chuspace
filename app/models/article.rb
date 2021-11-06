# frozen_string_literal: true

require 'marcel'
require 'down/http'

class Article < ApplicationRecord
  extend FriendlyId
  include MeiliSearch, Commitable, Markdownable
  VALID_MIME = 'text/markdown'

  friendly_id :front_matter_permalink_or_title, use: %i[history finders], slug_column: :permalink

  belongs_to :blog
  belongs_to :author, class_name: 'User'
  has_rich_text :blob_content
  markdownable :content

  before_validation :assign_title
  validates :title, :blob_path, :blog, :author_id, :blob_sha, presence: true
  validates :blob_path, uniqueness: { scope: :blog_id }

  delegate :storage, :repo_fullname, to: :blog
  delegate :name, :permalink, to: :blog, prefix: true
  delegate :name, to: :author, prefix: true
  delegate :front_matter, :content, to: :parsed_blob_content

  meilisearch do
    attribute :title, :intro, :visibility, :tags, :published_at
    searchable_attributes %i[title intro visibility tags author_name blog_name blog_permalink]
    filterable_attributes %i[author]
    add_attribute :author_name, :blog_name, :blog_permalink
  end

  def self.create_from_git_blob(blob:, blog:, author:)
    mime = Marcel::MimeType.for name: blob.name
    return unless mime == VALID_MIME

    tempfile = Down::Http.download(blob.download_url)

    Article.create!(
      blog: blog,
      author: author,
      blob_path: blob.path,
      blob_sha: blob.sha,
      blob_content: tempfile.read
    )
  end

  def content_to_html
    MarkdownRenderer.new.render(markdown_ast)
  end

  def git_blob
    @git_blob ||= storage.adapter.blob(
      fullname: repo_fullname,
      path: blob_path
    )
  end

  def front_matter_permalink_or_title
    front_matter['permalink'] || front_matter['title'] || markdown_ast.first.to_plaintext
  end

  private

  def assign_title
    self.title = front_matter['title'] || markdown_ast.first.to_plaintext
  end

  def parsed_blob_content
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(blob_content.to_plain_text)
  end
end

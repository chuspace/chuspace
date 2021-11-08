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
  markdownable :content

  before_validation :assign_title
  validates :blob_path, uniqueness: { scope: :blog_id }
  validates :blob_path, :blog, :author_id, :blob_sha, presence: true
  validates :title, :content_html, :published_at, presence: true, if: :published?

  delegate :storage, :repo_fullname, to: :blog
  delegate :name, :permalink, to: :blog, prefix: true
  delegate :name, to: :author, prefix: true
  delegate :front_matter, :content, to: :parsed_content

  meilisearch do
    attribute :title, :intro, :visibility, :tags, :published_at
    searchable_attributes %i[title intro visibility tags author_name blog_name blog_permalink]
    filterable_attributes %i[author]
    add_attribute :author_name, :blog_name, :blog_permalink
  end

  def self.create_from_git_blob(blob:, blog:, author:)
    mime = Marcel::MimeType.for name: blob.name
    return unless mime == VALID_MIME

    blob_content = blog.git_blob(path: blob.path).content
    markdown_ast = MarkdownParserService.call(blog: blog, content: blob_content)

    Article.create(
      blog: blog,
      author: author,
      blob_path: blob.path,
      blob_sha: blob.sha,
      readme: blob.path == blog.readme_path,
      blob_content: blob_content,
      md_content: markdown_ast.to_commonmark,
      html_content: MarkdownRenderer.new.render(markdown_ast)
    )
  end

  def self.without_readme
    where(readme: false)
  end

  def published?
    published_at && published_at < Time.current
  end

  def front_matter_str
    str = "---\n"

    front_matter.each do |key, value|
      str += "#{key}: '#{value}'"
      str += "\n"
    end

    str += '---'
  end

  def front_matter_permalink_or_title
    front_matter['permalink'] || front_matter['title'] || markdown_ast.first.to_plaintext
  end

  private

  def assign_title
    self.title ||= front_matter['title']
  end

  def parsed_content
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(content_md)
  end
end

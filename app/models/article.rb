# frozen_string_literal: true

class Article
  include ActiveModel::Model
  attr_accessor :id, :title, :intro, :published_at, :visibility, :tags, :filename, :blog, :content, :path, :front_matter
  delegate :repo_fullname, :repo_drafts_path, to: :blog

  def initialize(attributes = {})
    super

    @published ||= false
    @visibility ||= 'internal'
    @tags ||= []
  end

  def commits
    blog.storage.adapter.commits(fullname: repo_fullname, path: path)
  end

  def create
    path = "#{repo_drafts_path}/#{title.parameterize}.md"
    storage.adapter.create_blob(fullname: repo_fullname, path: path, content: base64_blob_content, message: nil)
  end

  def update
    storage.adapter.create_blob(fullname: repo_fullname, path: path, content: base64_blob_content, message: nil)
  end

  def delete
    storage.adapter.delete_blob(fullname: repo_fullname, path: path, id: id)
  end

  def base64_blob_content
    Base64.strict_encode64(content)
  end

  def persisted?
    id && path
  end

  def self.from(response, blog)
    case response
    when Array then response.map { |blob| Article.from(blob, blog) }
    else
      content = Base64.decode64(response.content).force_encoding('UTF-8')
      yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
      parsed = FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(content)

      front_matter_str = "---\n"
      parsed.front_matter.each do |key, value|
        front_matter_str += "#{key}: '#{value}'"
        front_matter_str += "\n"
      end

      front_matter_str += '---'
      title = parsed.front_matter['title'] || parsed.content.first(80)

      Article.new(
        id: response.id,
        title: title,
        intro: parsed.front_matter['description'],
        published_at: parsed.front_matter['published_at'],
        visibility: parsed.front_matter['visibility'],
        tags: parsed.front_matter['tags'] || parsed.front_matter['category'],
        front_matter: front_matter_str,
        blog: blog,
        filename: response.name,
        path: response.path,
        content: parsed.content
      )
    end
  end

  def to_param
    id
  end
end

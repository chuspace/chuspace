# frozen_string_literal: true

class Draft < Git::Blob
  CodeBlock = Struct.new(:content, :language)

  attribute :publication, Publication
  validates :path, :name, markdown: true
  validates :publication, presence: true

  kredis_string :local_content, expires_in: 1.day, key: :local_content_key

  def body
    parsed.content
  end

  def content_html(content: body)
    doc = CommonMarker.render_doc(content)
    PostHtmlRenderer.new(publication: publication).render(doc).html_safe
  end

  def date
    front_matter.dig(publication.front_matter.date)
  end

  def decoded_content
    Base64.decode64(content).force_encoding('UTF-8')
  end

  def front_matter
    parsed&.front_matter.presence || {}
  end

  def front_matter?
    !readme?
  end

  def front_matter_str
    str = front_matter.to_yaml
    str += "---\n"
  end

  def local_or_remote_content
    local_content.value.presence || decoded_content
  end

  def markdown_doc
    CommonMarker.render_doc(body)
  end

  def post
    @post ||= publication.posts.find_by(blob_path: path)
  end

  def publishable?
    post&.blob_sha != sha && !readme?
  end

  def persisted?
    id.present?
  end

  def preview_image_url_or_path
    images.first
  end

  def images
    images = []

    markdown_doc.walk { |node| images << node.url if node.type == :image }

    images
  end

  def snippets
    snippets = []

    markdown_doc.walk do |node|
      if node.type == :code_block
        snippets << CodeBlock.new(
          node.string_content,
          node.fence_info.split(/\s+/)[0]
        )
      end
    end

    snippets
  end

  def summary
    front_matter.dig(publication.front_matter.summary)
  end

  def title
    front_matter.dig(publication.front_matter.title)
  end

  def topics
    front_matter.dig(publication.front_matter.topics)
  end

  def readme?
    publication.repository.readme_path == path
  end

  def reload!
    self.assign_attributes(publication.repository.draft(path: path).attributes)
  end

  def relative_path
    if readme?
      path
    else
      base_path = Pathname.new(publication.repository.posts_folder)
      file_path = Pathname.new(path)
      file_path.relative_path_from(base_path).to_s
    end
  end

  def to_param
    relative_path
  end

  def to_post_attributes
    {
      date: date || Date.today,
      title: title,
      summary: summary,
      topic_list: topics,
      blob_path: path,
      blob_sha: id,
      body: body,
      body_html: content_html,
      commit_sha: commits.first&.id || commits.first&.sha
    }
  end

  def publish(author:, other_attributes: {})
    reload!

    post = publication.posts.build(author: author)
    post.assign_attributes(to_post_attributes)
    post.assign_attributes(other_attributes)
    post.save ? post : false
  end

  def stale?
    local_content.value.present? && local_content.value != decoded_content
  end

  def status
    stale? ? 'Uncommitted changes' : 'Everything up to date'
  end

  def new_template
    <<~STR
      ---
      title: Untitled
      summary:
      ---

    STR
  end

  private

  def local_content_key
    "#{publication.permalink}:#{path}:content"
  end

  def parsed
    yaml_loader =
      FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(
      decoded_content
    )
  rescue Psych::SyntaxError, Base64
    OpenStruct.new(front_matter: {}, content: decoded_content)
  end
end

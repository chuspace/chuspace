# frozen_string_literal: true

class Draft < Git::Blob
  attribute :publication, Publication
  validates :path, :name, markdown: true
  validates :publication, presence: true

  def body
    parsed.content
  end

  def content_html(content: body)
    doc = CommonMarker.render_doc(content)
    MarkdownRenderer.new.render(doc).html_safe
  end

  def collaboration_session
    publication.collaboration_sessions.active.find_by(blob_path: path)
  end

  def end_collaboration_session
    collaboration_session&.end_collaboration_session(blob_path: path) unless stale?
  end

  def collab?
    !readme?
  end

  def date
    parsed.front_matter.dig(publication.front_matter.date)
  end

  def decoded_content
    Base64.decode64(content).force_encoding('UTF-8')
  end

  def decoded_collaboration_session_content
    $ydoc.parse(ydoc: collaboration_session.current_ydoc) if collaboration_session&.current_ydoc&.present?
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
    image = nil

    markdown_doc.walk do |node|
      if node.type == :image
        image = node.url
        break
      end
    end

    image
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

  def redis_key
    "#{publication.permalink}:#{path}"
  end

  def readme?
    publication.repo.readme_path == path
  end

  def relative_path
    if readme?
      path
    else
      base_path = Pathname.new(publication.repo.posts_folder)
      file_path = Pathname.new(path)
      file_path.relative_path_from(base_path).to_s
    end
  end

  def stale?
    decoded_collaboration_session_content &&
      decoded_collaboration_session_content != decoded_content
  end

  def status
    if stale?
      'Uncommitted changes'
    else
      'Everything up to date'
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

  def publish(author:)
    publication.posts.create(author: author, **to_post_attributes)
  end

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(decoded_content)
  rescue Psych::SyntaxError, Base64
    OpenStruct.new(front_matter: {}, content: decoded_content)
  end
end

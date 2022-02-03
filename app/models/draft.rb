# frozen_string_literal: true

class Draft < Git::Blob
  # Add until it's added to upstream
  def self.kredis_boolean(name, key: nil, config: :shared, after_change: nil, expires_in: nil)
    kredis_connection_with __method__, name, key, config: config, after_change: after_change, expires_in: expires_in

    define_method("#{name}?") do
      send(name).value == true
    end
  end

  kredis_boolean :stale, expires_in: 1.week, key: ->(draft) { "#{draft.publication.permalink}:draft:#{draft.path}:stale" }
  kredis_string  :local_content, expires_in: 1.week, key: ->(draft) { "#{draft.publication.permalink}:draft:#{draft.path}:local_content" }

  attribute :publication, Publication
  validates :path, :name, markdown: true

  def body
    parsed.content
  end

  def content_html
    MarkdownRenderer.new.render(markdown_doc).html_safe
  end

  def date
    parsed.front_matter.dig(publication.front_matter.date)
  end

  def decoded_content
    Base64.decode64(content).force_encoding('UTF-8')
  end

  def front_matter
    parsed&.front_matter.presence || {}
  end

  def markdown_doc
    CommonMarker.render_doc(parsed.content)
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

  def relative_path
    base_path = Pathname.new(publication.repo.posts_folder)
    file_path = Pathname.new(path)
    file_path.relative_path_from(base_path).to_s
  end

  def to_param
    relative_path
  end

  def to_post_attributes
    {
      date: date,
      title: title,
      summary: summary,
      topic_list: topics,
      blob_path: path,
      blob_sha: id,
      commit_sha: commits.first&.id || commits.first&.sha
    }
  end

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(decoded_content)
  rescue Psych::SyntaxError, Base64
    OpenStruct.new(front_matter: {}, content: decoded_content)
  end
end

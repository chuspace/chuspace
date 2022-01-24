# frozen_string_literal: true

class Draft < ActiveType::Object
  attribute :id, :string
  attribute :path, :string
  attribute :name, :string
  attribute :commit_message, :string
  attribute :type, :string
  attribute :raw_content, :string, default: proc { '' }
  attribute :publication, Publication.new

  validates :path, :name, :publication, presence: true
  validates :path, :name, markdown: true

  def body
    parsed.content
  end

  def repo_fullname
    publication.repo.fullname
  end

  def last_commit
    publication.git_repository.git_adapter.commits(path: path)&.first
  end

  def commit!(author: Current.user, committer: GitConfig.new.committer)
    fail ArgumentError, 'Author must be set' if author.blank?
    fail ArgumentError, 'Committer must be set' if committer.blank?

    publication.git_repository.git_adapter.create_or_update_blob(
      path: path,
      content: raw_content,
      sha: id,
      message: commit_message,
      committer: committer,
      author: {
        name: author.name,
        email: author.email,
        date: Date.today
      }
    )
  end

  def content_html
    MarkdownRenderer.new.render(markdown_doc).html_safe
  end

  def date
    parsed.front_matter.dig(publication.front_matter.date)
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

  def post_attributes
    {
      date: date,
      title: title,
      summary: summary,
      topic_list: topics,
      body: body,
      body_html: content_html,
      blob_path: path,
      blob_sha: id,
      commit_sha: last_commit&.id || last_commit&.sha
    }
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

  def decoded_raw_content
    Base64.decode64(raw_content).force_encoding('UTF-8')
  end

  def relative_path
    base_path = Pathname.new(publication.repo.posts_folder)
    file_path = Pathname.new(path)
    file_path.relative_path_from(base_path).to_s
  end

  def to_param
    relative_path
  end

  def to_raw_content(title:, summary:, date: nil, topics: nil, body:)
    new_front_matter = front_matter.merge(
      "#{publication.front_matter.title}" => title,
      "#{publication.front_matter.summary}" => summary,
      "#{publication.front_matter.date}" => date,
      "#{publication.front_matter.topics}" => topics
    ).delete_if { |key, value| value.blank? }

    front_matter_str = <<~STR
      #{new_front_matter.to_yaml}
      ---
    STR

    Base64.encode64([front_matter_str, body].join("\n"))
  end

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(decoded_raw_content)
  rescue Psych::SyntaxError, Base64
    OpenStruct.new(front_matter: {}, content: decoded_raw_content)
  end
end

# frozen_string_literal: true

class Draft
  include ActiveModel::API

  attr_accessor :blob, :front_matter_settings
  validates :blob, :front_matter_settings, presence: true

  delegate :id, :name, :path, :type, to: :blob
  delegate :front_matter, :content, to: :parsed

  def self.for(blob:, front_matter_settings:)
    new(blob: blob, front_matter_settings: front_matter_settings)
  end

  def date
    parsed.front_matter.dig(front_matter_settings.date)
  end

  def summary
    parsed.front_matter.dig(front_matter_settings.summary)
  end

  def title
    parsed.front_matter.dig(front_matter_settings.title)
  end

  def topics
    parsed.front_matter.dig(front_matter_settings.topics)
  end

  def body
    parsed.content
  end

  def content_html
    MarkdownRenderer.new.render(markdown_doc).html_safe
  end

  def markdown_doc
    CommonMarker.render_doc(parsed.content)
  end

  private

  def parsed
    decoded_content = Base64.decode64(blob.content).force_encoding('UTF-8')
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(decoded_content)
  rescue Psych::SyntaxError
    OpenStruct.new(front_matter: {}, content: decoded_content)
  end
end

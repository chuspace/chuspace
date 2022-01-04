# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern

  included do
    before_save :save_front_matter_and_body
  end

  MarkdownConfig.new.front_matter['attributes'].each do |attribute|
    define_method attribute do
      front_matter[attribute.to_s]
    end
  end

  def blob_content_base64
    Base64.strict_encode64(blob_content)
  end

  def body_markdown_ast
    CommonMarker.render_doc(body)
  end

  def body_html
    MarkdownRenderer.new.render(body_markdown_ast).html_safe
  end

  private

  def save_front_matter_and_body
    self.front_matter = parsed.front_matter if parsed.front_matter
    self.body = parsed.content
  end

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(blob_content || '')
  rescue Psych::SyntaxError
    OpenStruct.new(content: blob_content)
  end
end

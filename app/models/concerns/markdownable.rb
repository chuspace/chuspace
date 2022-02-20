# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern

  def body_markdown_ast
    CommonMarker.render_doc(parsed.content)
  end

  def body_html
    MarkdownRenderer.new.render(body_markdown_ast).html_safe
  end

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(blob_content || '')
  rescue Psych::SyntaxError
    OpenStruct.new(content: blob_content)
  end
end

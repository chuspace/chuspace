# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern

  def title
    front_matter.dig('title')
  end

  def summary
    front_matter.dig('summary')
  end

  def published_at
    front_matter.dig('published_at') || front_matter.dig('date')
  end

  def topics
    front_matter.dig('topics') || front_matter.dig('categories')
  end

  def encode
    Base64.strict_encode64(content)
  end

  def doc
    MarkdownParserService.call(blog: blog, content: parsed.content)
  end

  def html
    MarkdownRenderer.new.render(doc).html_safe
  end

  def front_matter_str
    str = "---\n"

    front_matter.each do |key, value|
      str += "#{key}: '#{value}'"
      str += "\n"
    end

    str += '---'
  end

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(content)
  end

  delegate :front_matter, to: :parsed
end

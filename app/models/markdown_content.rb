# frozen_string_literal: true

class MarkdownContent
  attr_reader :content

  def initialize(content:)
    @content = content
  end

  def ast
    CommonMarker.render_doc(body || '')
  end

  def body
    str = ''
    str += "# #{title}\n" if title
    str += "## #{summary}\n" if summary
    str += parsed.content
  end

  def base64
    Base64.strict_encode64(content)
  end

  def html
    MarkdownRenderer.new.render(ast).html_safe
  end

  def published_at
    front_matter.dig('published_at') || front_matter.dig('date')
  end

  def summary
    front_matter.dig('summary') || front_matter.dig('intro') || front_matter.dig('description')
  end

  def title
    front_matter.dig('title')
  end

  def topics
    front_matter.dig('topics') || front_matter.dig('categories') || front_matter.dig('tags')
  end

  delegate :front_matter, to: :parsed

  private

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(content)
  end
end

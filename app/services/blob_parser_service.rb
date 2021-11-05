class BlobParserService
  attr_reader :blob_content
  delegate :content, :front_matter, to: :parsed

  def initialize(blob_content:)
    @blob_content = blob_content
  end

  def self.call(blob_content:)
    new(blob_content: blob_content)
  end

  def title
    front_matter['title'] || markdown_ast.first.content
  end

  def front_matter_str
    str = "---\n"

    front_matter.each do |key, value|
      str += "#{key}: '#{value}'"
      str += "\n"
    end

    str += '---'
  end

  def images_paths
    paths = []

    markdown_ast.walk do |node|
      next unless image?(node)

      paths << node.url
    end

    paths
  end

  def markdown_ast
    @markdown_ast = CommonMarker.render_doc(content)
  end

  def content_html
    MarkdownRenderer.new.render(markdown_ast)
  end

  private

  def image?(node)
    node.type == :image
  end

  def url_or_mailto?(url_str)
    url = URI.parse(url_str)
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url.kind_of?(URI::MailTo)
  end

  def parsed
    yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
    FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(blob_content)
  end
end

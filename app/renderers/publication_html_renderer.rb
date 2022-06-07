# frozen_string_literal: true

class PublicationHtmlRenderer < CommonMarker::HtmlRenderer
  attr_reader :publication

  def initialize(publication:)
    super(options: %i[DEFAULT], extensions: %i[tagfilter])

    @headers = 1
    @code_blocks = 1
    @publication = publication
  end

  def header(node)
    slug = string_content_for(node).to_slug&.to_ascii&.normalize&.to_s
    block { out('<h', node.header_level, ' id="', slug, '">', :children, '</h', node.header_level, '>') }
  end

  def link(node)
    if URI.parse(node.url).absolute?
      out('<a href="', node.url.nil? ? '' : escape_href(node.url), '"')
      out(' title="', escape_html(node.title), '"') if node.title && !node.title.empty?
      out(' target="', '_blank', '"')
      out(' rel="', 'noopener noreferrer', '"')
      out('>', :children, '</a>')
    else
      out('<a href="', node.url.nil? ? '' : escape_href(node.url), '"')
      out(' title="', escape_html(node.title), '"') if node.title && !node.title.empty?
      out('>', :children, '</a>')
    end
  end

  def image(node)
    out('<lazy-image')
    out(' src="', escape_href(Rails.application.routes.url_helpers.publication_asset_path(publication, path: node.url)), '"')
    out(' filename="', escape_href(File.basename(node.url)), '"')
    plain { out(' alt="', :children, '"') }
    out(' title="', escape_html(node.title), '"') if node.title && !node.title.empty?
    out(' >')
    out('</lazy-image>')
  end

  def code_block(node)
    block do
      out("<code-editor#{sourcepos(node)}")
      out(' mode="', node.fence_info.split(/\s+/)[0], '"') if node.fence_info && !node.fence_info.empty?
      out(' content="', escape_html(node.string_content), '"')
      out(' readonly="nocursor"')
      out(' id="', @code_blocks, '"')
      out(' wrapper')
      out('></code-editor>')
    end
  end

  def render(node)
    @headers     += 1 if node.type == :header
    @code_blocks += 1 if node.type == :code_block

    super(node)
  end

  private

  def string_content_for(node, content = '')
    node.each do |subnode|
      case subnode.type.to_sym
      when :text
        content += subnode.string_content
      else
        content += string_content_for(subnode)
      end
    end

    content
  end
end

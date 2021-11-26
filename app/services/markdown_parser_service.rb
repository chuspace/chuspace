# frozen_string_literal: true

require 'marcel'

class MarkdownParserService
  attr_reader :blog, :content, :markdown_doc

  def initialize(blog:, content:)
    @blog = blog
    @markdown_doc = CommonMarker.render_doc(content || '')
  end

  def self.call(blog:, content:)
    new(blog: blog, content: content).parse
  end

  def parse
    markdown_doc.walk do |node|
      if node.type == :image
        uri = URI.parse(node.url)
        path = node.url
        mime = Marcel::MimeType.for name: File.basename(uri.path)

        if uri.relative? && mime.include?('image/')
          path = CGI.escape(path.delete_prefix('/'))
        end

        node.url = Rails.application.routes.url_helpers.blog_assets_path(blog, path: path)
      end
    end

    @markdown_doc
  end
end

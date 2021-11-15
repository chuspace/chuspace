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
        path = node.url if uri.absolute?
        mime = Marcel::MimeType.for name: File.basename(uri.path)
        path = Rails.application.routes.url_helpers.blog_blobs_path(blog, path: CGI.escape(node.url)) if uri.relative? && mime.include?('image/')
        node.url = path
      end

      if node.type == :link
        uri = URI.parse(node.url)
        path = node.url if uri.absolute?
        path = Rails.application.routes.url_helpers.blog_article_path(blog, path: CGI.escape(node.url)) if uri.relative? && uri.ends_with?('.md')
        node.url = path
      end
    end

    @markdown_doc
  end
end

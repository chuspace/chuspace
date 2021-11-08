# typed: true
# frozen_string_literal: true

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
        node.url = Rails.application.routes.url_helpers.blog_blobs_path(blog, path: CGI.escape(node.url))
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

  private

  def url_or_mailto?(url_str)
    url = URI.parse(url_str)
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url.kind_of?(URI::MailTo)
  end
end

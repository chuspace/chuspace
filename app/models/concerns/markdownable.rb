module Markdownable
  extend ActiveSupport::Concern

  class_methods do
    attr_reader :content_attribute

    def markdownable(attribute, scope: nil)
      @content_attribute = attribute
    end
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
    @markdown_ast = CommonMarker.render_doc(send(self.class.content_attribute) || '')
  end

  private

  def image?(node)
    node.type == :image
  end

  def url_or_mailto?(url_str)
    url = URI.parse(url_str)
    url.kind_of?(URI::HTTP) || url.kind_of?(URI::HTTPS) || url.kind_of?(URI::MailTo)
  end
end

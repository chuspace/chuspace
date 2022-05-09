# frozen_string_literal: true

class MarkdownDoc
  CodeBlock = Struct.new(:id, :content, :language)
  ImageNode = Struct.new(:id, :url, :filename, :external)
  IMAGE_NODE = :image
  CODE_NODE  = :code_block

  attr_reader :doc

  def initialize(content:)
    @content = content
    @doc     = CommonMarker.render_doc(content)
  end

  def images
    images = []
    idx = 1

    doc.walk do |node|
      next unless node.type == IMAGE_NODE
      images << ImageNode.new(idx, node.url, File.basename(node.url), URI.parse(node.url).absolute?)

      idx += 1
    end

    images
  end

  def preview_image
    images.first
  end

  def snippets
    snippets = []
    idx = 1

    doc.walk do |node|
      next unless node.type == CODE_NODE

      snippets << CodeBlock.new(
        idx,
        node.string_content,
        node.fence_info.split(/\s+/)[0]
      )

      idx += 1
    end

    snippets
  end

  def snippets?
    snippets.any?
  end
end

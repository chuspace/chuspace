# frozen_string_literal: true

module Drafts
  module Markdown
    extend ActiveSupport::Concern

    def content_html
      PostHtmlRenderer.new(publication: publication).render(markdown_doc.doc).html_safe
    end

    def markdown_doc
      @markdown_doc ||= MarkdownDoc.new(content: body)
    end

    def new_template
      <<~STR
        ---
        title: Untitled
        summary:
        ---

      STR
    end

    private

    def parsed
      yaml_loader = FrontMatterParser::Loader::Yaml.new(allowlist_classes: [Date, Time])
      FrontMatterParser::Parser.new(:md, loader: yaml_loader).call(decoded_content)

    rescue Psych::SyntaxError, Base64
      OpenStruct.new(front_matter: {}, content: decoded_content)
    end
  end
end

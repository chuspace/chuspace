# frozen_string_literal: true

module Drafts
  module Yaml
    extend ActiveSupport::Concern

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

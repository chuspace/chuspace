# frozen_string_literal: true

class MarkdownConfig < ApplicationConfig
  attr_config(
    extensions: %w[.markdown .mdown .mkdn .mkd .md .text .txt],
    front_matter: {
      attributes: %w[title summary topics date],
      attributes_map: <<~YAML
        ---
        title: 'title'
        summary: 'summary'
        topics: 'topics'
        date: 'date'
        ---
      YAML
    }
  )

  def self.valid?(name:)
    defaults['extensions'].include?(File.extname(name))
  end

  def self.default_front_matter
    defaults['front_matter']['attributes'].each_with_object({}) do |key, hash|
      hash[key] = ''
    end
  end
end

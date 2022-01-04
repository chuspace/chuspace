# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern

  included do
    delegate :title, :summary, :published_at, :topics, :html, :body, :front_matter_str, to: :parsed_content
  end

  def parsed_content
    MarkdownContent.new(content: content)
  end
end

# frozen_string_literal: true

module Markdownable
  extend ActiveSupport::Concern

  included do
    delegate :title, :summary, :published_at, :topics, :html, :body, to: :parsed_content
  end

  def parsed_content
    MarkdownContent.new(content: content)
  end
end

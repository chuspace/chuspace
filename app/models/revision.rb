# frozen_string_literal: true

class Revision < ApplicationRecord
  include Sequenced

  belongs_to :post, touch: true
  belongs_to :blog, touch: true
  belongs_to :author, class_name: 'User', optional: true, touch: true
  has_one    :edition, dependent: :destroy, inverse_of: :revision

  delegate :title, :summary, :published_at, :topics, :html, :body, to: :parsed_content

  class << self
    alias current first
  end

  def to_param
    sha
  end

  def parsed_content
    MarkdownContent.new(content: content)
  end
end

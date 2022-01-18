# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :publication, touch: true
  belongs_to :author, class_name: 'User', touch: true

  validates :title, :summary, :date, :body, :body_html, :blob_sha, :commit_sha, :visibility, presence: true
  validates :blob_path, presence: :true, uniqueness: { scope: :publication_id }, markdown: true
  validates :blob_sha, presence: :true, uniqueness: { scope: :publication_id }

  before_validation :set_visibility

  enum visibility: PublicationConfig.to_enum, _suffix: true

  acts_as_taggable_on :topics

  has_one_attached :preview_image do |attachable|
    attachable.variant :post, resize_to_limit: [800, 300]
    attachable.variant :list, resize_to_limit: [250, 150]
    attachable.variant :icon, resize_to_limit: [64, 64]
  end

  class << self
    def valid_blob?(name:)
      MarkdownConfig.new.extensions.include?(File.extname(name))
    end
  end

  private

  def set_visibility
    self.visibility ||= publication.visibility
  end
end

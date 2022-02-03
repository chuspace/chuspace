# frozen_string_literal: true

class Post < ApplicationRecord
  include Immutable
  extend FriendlyId

  self.implicit_order_column = 'version'

  belongs_to :publication, touch: true
  belongs_to :author, class_name: 'User', touch: true

  validates :title, :summary, :permalink, :date, :body, :body_html, :blob_sha, :commit_sha, :visibility, presence: true
  validates :blob_path, presence: :true, uniqueness: { scope: :publication_id }, markdown: true
  validates :version, presence: :true, uniqueness: { scope: :publication_id }

  before_validation :set_visibility
  before_validation :assign_next_version, on: :create

  enum visibility: PublicationConfig.to_enum, _suffix: true

  acts_as_taggable_on :topics

  friendly_id :slug_candidates, use: %i[slugged history], slug_column: :permalink

  has_one_attached :preview_image do |attachable|
    attachable.variant :post, resize_to_limit: [800, 300]
    attachable.variant :list, resize_to_limit: [250, 150]
    attachable.variant :icon, resize_to_limit: [64, 64]
  end

  def short_commit_sha
    commit_sha.first(7)
  end

  private

  def slug_candidates
    %i[%i[title short_commit_sha] %i[name short_commit_sha version]]
  end

  def set_visibility
    self.visibility ||= publication.visibility
  end

  def assign_next_version
    self.version = (publication.posts.maximum(:version) || 0) + 1
  end
end

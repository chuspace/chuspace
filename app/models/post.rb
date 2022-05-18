# frozen_string_literal: true

class Post < ApplicationRecord
  extend FriendlyId
  include ReadingTime, Metatagable

  belongs_to :publication, touch: true
  belongs_to :author, class_name: 'User', touch: true
  has_many   :revisions, dependent: :delete_all, inverse_of: :post
  has_many   :publishings, dependent: :delete_all, inverse_of: :post
  has_many   :images, ->(post) { where(draft_blob_path: post.blob_path) }, through: :publication, dependent: :delete_all, source: :images
  has_one    :featured_image, ->(post) { where(draft_blob_path: post.blob_path, featured: true) }, through: :publication, class_name: 'Image', source: :images

  validates :title, :permalink, :blob_path, :body, :blob_sha, :commit_sha, :visibility, presence: true
  validates :blob_path, uniqueness: { scope: :publication_id }, markdown: true
  validates :permalink, uniqueness: { scope: :permalink }

  before_validation :set_visibility

  after_create_commit :record_publishing
  after_create_commit -> { CachePostImagesJob.perform_later(post: self) }

  enum visibility: PublicationConfig.to_enum, _suffix: true

  acts_as_votable
  acts_as_taggable_on :topics

  friendly_id :title, use: %i[slugged history scoped], slug_column: :permalink, scope: :publication

  scope :newest, -> { order(id: :desc) }
  scope :oldest, -> { order(:id) }

  delegate :repository, to: :publication

  def short_commit_sha
    commit_sha.first(7)
  end

  def draft
    repository.draft_at(path: blob_path, ref: commit_sha)
  end

  def stale?
    blob_sha != repository.draft(path: blob_path).sha
  end

  def markdown_doc
    MarkdownDoc.new(content: body)
  end

  def body_html
    PublicationHtmlRenderer.new(publication: publication).render(markdown_doc.doc)
  end

  def record_publishing
    publishings.create(post: self, author: Current.user, content: draft.decoded_content, commit_sha: commit_sha)
  end

  def cache_images
    markdown_doc.images.each do |image|
      publication.images.create(name: image.filename, draft_blob_path: blob_path, blob_path: image.url, featured: image.featured, external: image.external)
    end
  end

  private

  def set_visibility
    self.visibility ||= publication.visibility
  end
end

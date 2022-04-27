# frozen_string_literal: true

class Post < ApplicationRecord
  include Immutable
  extend FriendlyId

  self.implicit_order_column = 'version'

  belongs_to :publication, touch: true
  belongs_to :author, class_name: 'User', touch: true
  has_many   :revisions, dependent: :delete_all, inverse_of: :post

  validates :title, :permalink, :body, :body_html, :blob_sha, :commit_sha, :visibility, presence: true
  validates :blob_path, presence: :true, uniqueness: { scope: %i[version publication_id] }, markdown: true
  validates :version, presence: :true, uniqueness: { scope: :publication_id }

  before_validation :set_visibility
  before_validation :assign_next_version, on: :create
  after_create_commit :unpublish_previous_versions

  enum visibility: PublicationConfig.to_enum, _suffix: true

  acts_as_votable
  acts_as_taggable_on :topics

  friendly_id :slug_candidates, use: %i[slugged history scoped], slug_column: :permalink, scope: :publication

  has_one_attached :preview_image do |attachable|
    attachable.variant :post, resize_to_limit: [800, 300]
    attachable.variant :list, resize_to_limit: [250, 150]
    attachable.variant :icon, resize_to_limit: [64, 64]
    attachable.variant :social, resize_to_limit: [600, 315]
  end

  delegate :repository, to: :publication

  def self.default_scope
    where(published: true).order(date: :desc)
  end

  def draft
    repository.draft_at(path: blob_path, ref: commit_sha)
  end

  def short_commit_sha
    commit_sha.first(7)
  end

  def stale?
    blob_sha != repository.draft(path: blob_path).sha
  end

  def to_meta_tags
    {
      site: ChuspaceConfig.new.app[:name],
      title: title,
      image_src: preview_image.variant(:list),
      description: summary,
      keywords: topic_list,
      index: true,
      follow: true,
      author: author.name,
      canonical: canonical_url || Rails.application.routes.url_helpers.publication_post_url(publication, self),
      og: {
        title: :title,
        type: :article,
        description: :description,
        site_name: :site,
        image: preview_image.variant(:social),
        url: Rails.application.routes.url_helpers.publication_post_url(publication, self)
      },
      twitter: {
        title: :title,
        card: :summary,
        description: :description,
        site: ChuspaceConfig.new.app[:twitter],
        url: Rails.application.routes.url_helpers.publication_post_url(publication, self),
        image: preview_image.variant(:list)
      },
      article: { published_time: date, modified_time: updated_at, tag: topic_list, author: author.username }
    }
  end

  private

  def slug_candidates
    [[:title, :short_commit_sha]]
  end

  def set_visibility
    self.visibility ||= publication.visibility
  end

  def assign_next_version
    self.version = (publication.posts.maximum(:version) || 0) + 1
  end

  def unpublish_previous_versions
    publication.posts.where(blob_path: blob_path).where('version < ?', version).update_all(published: false)
  end
end

# frozen_string_literal: true

class Post < ApplicationRecord
  VALID_MIME = 'text/markdown'.freeze

  belongs_to :blog, touch: true
  has_many   :revisions, dependent: :delete_all, inverse_of: :post
  has_many   :editions, through: :revisions, dependent: :delete_all

  validates :blob_path, presence: :true, uniqueness: { scope: :blog_id }

  after_create_commit :sync_post_revisions
  before_validation   :set_visibility

  enum visibility: {
    private: 'private',
    public: 'public',
    subscriber: 'subscriber'
  }, _suffix: true


  class << self
    def published
      joins(revisions: :edition)
    end

    def drafts
      joins(:revisions).distinct(:revision_id)
    end

    def valid_mime?(name:)
      VALID_MIME == Marcel::MimeType.for(name: name)
    end
  end

  def git_blob(ref: nil)
    blog.repository.blob(path: blob_path, ref: ref)
  end

  def git_commits
    blog.repository.commits(path: blob_path)
  end

  def published?
    editions.any?
  end

  def status
    editions.any? ? 'published' : 'draft'
  end

  private

  def sync_post_revisions
    SyncPostRevisionsJob.perform_later(post: self)
  end

  def set_visibility
    self.visibility ||= blog.visibility
  end
end

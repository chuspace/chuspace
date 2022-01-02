# frozen_string_literal: true

class Post < ApplicationRecord
  include Sourceable

  VALID_MIME = 'text/markdown'.freeze
  DEFAULT_FRONT_MATTER = <<~YAML
    ---
    title: Untitled
    summary:
    topics:
    published_at:
    ---
  YAML

  belongs_to :blog, touch: true
  belongs_to :author, class_name: 'User', touch: true
  has_many   :revisions, dependent: :destroy, inverse_of: :post
  has_many   :editions, through: :revisions, dependent: :destroy

  validates :blob_path, presence: :true, uniqueness: { scope: :blog_id }, markdown: true
  validate  :blob_paths_are_stored_correctly

  before_validation :set_root_folder, :set_visibility

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
      %w[.md .markdown .mdx].include?(File.extname(name))
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
    published? ? 'published' : 'draft'
  end

  private

  def blob_paths_are_stored_correctly
    unless (blog.repo_drafts_folder && blob_path&.include?(blog.repo_drafts_folder)) || blob_path&.include?(blog.repo_posts_folder)
      errors.add(:blob_path, 'should be contained in valid folder')
    end
  end

  def set_root_folder
    if blob_path.present?
      self.blob_path = if blob_path.include?('/')
        blob_path
      else
        File.join(blog.repo_drafts_or_posts_folder, File.basename(blob_path))
      end
    end
  end

  def set_visibility
    self.visibility ||= blog.visibility
  end
end

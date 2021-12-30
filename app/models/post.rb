# frozen_string_literal: true

class Post < ApplicationRecord
  VALID_MIME = 'text/markdown'.freeze

  belongs_to :blog, touch: true
  belongs_to :author, class_name: 'User', touch: true

  validates :blob_path, presence: :true, uniqueness: { scope: :blog_id }, markdown: true
  validate  :blob_paths_are_stored_correctly

  before_validation :set_root_folder, :set_visibility

  enum visibility: {
    private: 'private',
    public: 'public',
    subscriber: 'subscriber'
  }, _suffix: true

  class << self
    def valid_mime?(name:)
      %w[.md .mdx .markdown].include?(File.extname(name))
    end
  end

  def git_blob(ref: nil)
    blog.repository.blob(path: blob_path, ref: ref)
  end

  def git_commits
    blog.repository.commits(path: blob_path)
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

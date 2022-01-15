# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :publication, touch: true
  belongs_to :author, class_name: 'User', touch: true

  validates :title, :summary, :date, :body, :body_html, :blob_sha, :commit_sha, :visibility, presence: true
  validates :blob_path, presence: :true, uniqueness: { scope: :publication_id }, markdown: true
  validates :blob_sha, presence: :true, uniqueness: { scope: :publication_id }

  before_validation :set_visibility

  enum visibility: PublicationConfig.to_enum, _suffix: true

  class << self
    def valid_blob?(name:)
      MarkdownConfig.new.extensions.include?(File.extname(name))
    end
  end

  def git_blob(ref: nil)
    publication.repository.blob(path: blob_path, ref: ref)
  end

  def git_commits
    publication.repository.commits(path: blob_path)
  end

  private

  def set_visibility
    self.visibility ||= publication.visibility
  end
end

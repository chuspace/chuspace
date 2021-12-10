# frozen_string_literal: true

class Revision < ApplicationRecord
  self.implicit_order_column = 'number'

  belongs_to :post, touch: true
  belongs_to :blog, touch: true
  belongs_to :author, class_name: 'User', optional: true, touch: true
  has_one    :edition, dependent: :destroy, inverse_of: :revision

  delegate :title, :summary, :published_at, :topics, :html, :body, to: :parsed_content

  validates :number, uniqueness: { scope: :post_id }
  before_validation :assign_next_number_sequence, on: :create
  before_create     :create_git_commit, if: -> { sha.blank? }

  class << self
    alias current last
  end

  def to_param
    sha
  end

  def parsed_content
    MarkdownContent.new(content: content)
  end

  private

  def assign_next_number_sequence
    self.number = post.revisions.last&.number.to_i + 1
  end

  def create_git_commit
    blob = blog.storage.adapter.update_blob(fullname: blog.repo_fullname, path: post.blob_path, content: Base64.encode64(content), message: message.presence, sha: post.git_blob.sha)
    self.sha = blob.commit.sha
  end
end

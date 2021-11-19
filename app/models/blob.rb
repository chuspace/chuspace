# frozen_string_literal: true

class Blob < ApplicationRecord
  MIMES = %w[text/markdown image/jpg image/jpeg image/png image/bmp image/avif image/gif].freeze
  COMMIT_ACTIONS = %i[create update delete].freeze
  belongs_to :repository
  delegate :blog, :storage, :user, to: :repository
  has_many :commits, dependent: :delete_all
  has_one_attached :content

  def git_commits
    storage.adapter.commits(fullname: repository.name, path: path)
  end

  def base64_blob_content
    Base64.strict_encode64(content)
  end

  private

  def sync_commits
    SyncBlobCommitsJob.perform_later(blob: blob)
  end
end

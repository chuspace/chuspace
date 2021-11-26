# frozen_string_literal: true

class Draft < ApplicationRecord
  belongs_to :blog, touch: true

  delegate :storage, to: :blog

  has_many :revisions, dependent: :delete_all, inverse_of: :draft
  has_many :editions, through: :revisions, dependent: :delete_all

  after_create_commit :sync_draft_commits

  def blob(ref: nil)
    storage.adapter.blob(fullname: blog.repo_fullname, path: blob_path, ref: ref)
  end

  def git_commits
    storage.adapter.commits(fullname: blog.repo_fullname, path: blob_path)
  end

  def latest_edition
    editions.first
  end

  alias current_edition latest_edition

  def latest_revision
    revisions.first
  end

  alias current_revision latest_revision

  private

  def sync_draft_commits
    SyncDraftCommitsJob.perform_later(draft: self)
  end
end

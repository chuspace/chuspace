# frozen_string_literal: true

module Commitable
  extend ActiveSupport::Concern

  COMMITTER_USER = 'Chuspace'

  included do
    before_create :create_commit_on_git_remote, if: :chuspace_originator?
  end

  def git_commit
    blog.repository.commit(sha: sha)
  end

  private

  def create_commit_on_git_remote
    blob = blog.storage.adapter.create_or_update_blob(
      fullname: blog.repo_fullname,
      path: post.blob_path,
      content: Base64.encode64(content),
      message: message.presence,
      sha: nil,
      committer: GitConfig.new.committer,
      author: {
        name: author.name,
        email: author.email,
        date: Date.today
      }
    )

    self.sha = blob.commit.sha
    self.message = blob.commit.message
  end
end

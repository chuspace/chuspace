# frozen_string_literal: true

class SyncPostRevisionsJob < ApplicationJob
  queue_as :default

  def perform(post:)
    Revision.transaction do
      post.git_commits.each do |git_commit|
        git_blob = post.git_blob(ref: git_commit.sha)
        user = User.find_by(username: git_commit.author.login) || User.find_by(email: git_commit.commit.author.email)

        post.revisions.create!(
          message: git_commit.commit.message,
          author: user,
          blog: post.blog,
          fallback_author: git_commit.commit.author.to_h,
          fallback_committer: git_commit.commit.committer.to_h,
          sha: git_commit.sha,
          content: Base64.decode64(git_blob.content)
        )
      end
    end
  end
end

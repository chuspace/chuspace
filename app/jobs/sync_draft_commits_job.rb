# frozen_string_literal: true

class SyncDraftCommitsJob < ApplicationJob
  queue_as :default

  def perform(draft:)
    Revision.transaction do
      draft.git_commits.each do |git_commit|
        git_blob = draft.blob(ref: git_commit.sha)
        user = User.find_by(username: git_commit.author.login) || User.find_by(email: git_commit.commit.author.email)

        draft.revisions.create!(
          message: git_commit.commit.message,
          author: user,
          fallback_author: git_commit.commit.author.to_h,
          fallback_committer: git_commit.commit.committer.to_h,
          sha: git_commit.sha,
          content: Base64.decode64(git_blob.content)
        )
      end
    end
  end
end

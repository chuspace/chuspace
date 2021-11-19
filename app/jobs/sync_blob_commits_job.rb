class SyncBlobCommitsJob < ApplicationJob
  queue_as :default

  def perform(blob:)
    Commit.transaction do
      blob.commits.delete_all
      blob.git_commits.each do |git_commit|
        commit = git_commit.commit
        blob.commits.create!(
          message: commit.message,
          sha: git_commit.sha || git_commit.id,
          author_name: commit.author.name,
          author_email: commit.author.email,
          committed_at: commit.author.date
        )
      end
    end
  end
end

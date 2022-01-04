# frozen_string_literal: true

class SyncRepositoryContentsJob < ApplicationJob
  queue_as :default

  def perform(blog:)
    Blog.transaction do
      Post.transaction do
        blog.repository.post_blobs.each do |git_blob|
          post = blog.posts.create!(
            blob_path: git_blob.path,
            author: blog.owner,
            originator: blog.git_provider.name
          )

          sync_revisions_for(post: post)
        end
      end

      blog.update!(
        readme: blog.repository.readme,
        repo_status: :synced,
      )
    end
  end

  private

  def sync_revisions_for(post:)
    Revision.transaction do
      post.git_commits.each do |git_commit|
        git_blob = post.git_blob(ref: git_commit.sha)
        user = User.find_by(username: git_commit.author&.login) || User.find_by(email: git_commit.commit&.author&.email)
        post.revisions.create!(
          message: git_commit.commit.message,
          committer: user,
          originator: post.blog.git_provider.name,
          fallback_committer: git_commit.commit.author.to_h,
          blob_sha: git_blob.sha,
          sha: git_commit.sha,
          blob_content: Base64.decode64(git_blob.content || '')
        )
      end
    end
  end
end

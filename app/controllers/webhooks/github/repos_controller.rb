# frozen_string_literal: true

module Webhooks
  module Github
    class ReposController < ActionController::API
      before_action :verify_signature, :set_commit, :verify_commit, :find_blog, :find_author

      def create
        @commit['added'].each do |blob_path|
          if blob_path == @blog.repo_readme_path
            update_readme
          else
            create_post(blob_path)
          end
        end

        @commit['removed'].each do |blob_path|
          if blob_path == @blog.repo_readme_path
            update_readme
          else
            delete_post(blob_path)
          end
        end

        @commit['modified'].each do |blob_path|
          if blob_path == @blog.repo_readme_path
            update_readme
          else
            update_post(blob_path)
          end
        end

        render head: :ok
      end

      private

      def create_post(blob_path)
        Post.transaction do
          post = @blog.posts.find_or_initialize_by(blob_path: blob_path)

          unless post.persisted?
            post.author = @author || @blog.owner
            post.save
            create_revision(post: post)
          end
        end
      end

      def delete_post(blob_path)
        @blog.posts.find_by(blob_path: blob_path)&.destroy
      end

      def update_post(blob_path)
        post = @blog.posts.find_by(blob_path: blob_path)

        if post
          create_revision(post: post)
        else
          create_post(blob_path)
        end
      end

      def update_readme
        @blog.update!(readme: @blog.repository.readme)
      end

      def create_revision(post:)
        Revision.transaction do
          git_blob = post.git_blob(ref: @commit['id'])

          post.revisions.create!(
            message: @commit['message'],
            committer: @author,
            originator: post.blog.git_provider.name,
            fallback_committer: @commit['author'] || @commit['committer'],
            sha: @commit['id'],
            blob_sha: git_blob.sha,
            blob_content: Base64.decode64(git_blob.content)
          )
        end
      end

      def find_blog
        @blog = Blog.find_by(repo_fullname: params['repository']['full_name'])
      end

      def find_author
        @author = @blog.members.find_by(username: @commit['author']['login'])
      end

      def set_commit
        event = JSON.parse(payload)
        @commit = event['head_commit']
      end

      def verify_signature
        signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Rails.application.credentials.webhooks[:secret], payload)
        head :forbidden unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      end

      def verify_commit
        head :ok if GitConfig.new.committer['name'] == @commit['committer']['name']
      end

      def payload
        @payload ||= request.body.read
      end
    end
  end
end

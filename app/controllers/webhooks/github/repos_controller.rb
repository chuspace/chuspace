# frozen_string_literal: true

module Webhooks
  module Github
    class ReposController < ActionController::API
      before_action :verify_signature, :set_commit, :verify_commit, :find_blog, :find_author

      def create
        @commit['added'].each do |blob_path|
          create_post(blob_path)
        end

        @commit['removed'].each do |blob_path|
          delete_post(blob_path)
        end

        @commit['modified'].each do |blob_path|
          update_post(blob_path)
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
        create_revision(post: post)
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
            content: Base64.decode64(git_blob.content)
          )
        end
      end

      def find_blog
        @blog = Blog.find_by(repo_fullname: params['repository']['full_name'])
      end

      def find_author
        @author = @blog.members.joins(:user).find_by(users: { username: @commit['author']['login'] })
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

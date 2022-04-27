# frozen_string_literal: true

module Webhooks
  module Github
    class ReposController < ActionController::API
      before_action :verify_signature, :set_commit, :verify_commit, :find_publication, :find_author

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
          post = @publication.posts.find_or_initialize_by(blob_path: blob_path)

          unless post.persisted?
            post.author = @author || @publication.owner
            post.save
          end
        end
      end

      def delete_post(blob_path)
        @publication.posts.find_by(blob_path: blob_path)&.destroy
      end

      def update_post(blob_path)
        post = @publication.posts.find_by(blob_path: blob_path)
        post.publish!
      end

      def find_publication
        @publication = Publication.find_by("repo ->'fullname' = ?", params['repository']['full_name'])
      end

      def find_author
        @author = @publication.members.find_by(username: @commit['author']['login'])
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
        if @commit.blank? || GitConfig.new.committer['name'] == @commit.dig('committer', 'name')
          head :ok
        end
      end

      def payload
        @payload ||= request.body.read
      end
    end
  end
end

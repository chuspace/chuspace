# frozen_string_literal: true

module Webhooks
  module Github
    class ReposController < ActionController::API
      before_action :verify_signature

      def create
        handle_event
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

      def handle_event
        data = JSON.parse(payload)

        if @installation = data['installation']
          handle_installation_update
        elsif @commit = data['head_commit']
          handle_commit
        end
      end

      def handle_commit
        if GitConfig.new.github.dig('committer', 'name') == @commit.dig('committer', 'name')
          head :ok
        else
          @publication = Repository.find_by(full_name: params['repository']['full_name'])
          @author = @publication.members.find_by(username: @commit['author']['login'])

          @commit['added'].each do |blob_path|
            create_post(blob_path)
          end

          @commit['removed'].each do |blob_path|
            delete_post(blob_path)
          end

          @commit['modified'].each do |blob_path|
            update_post(blob_path)
          end
        end
      end

      def handle_installation_update
        git_provider = GitProvider.github.find_by(app_installation_id: @installation['id'])

        unless git_provider&.adapter&.app_installed?(id: @installation['id']) && @installation['suspended_at'].blank?
          git_provider.revoke!
        end
      end

      def verify_signature
        signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), Rails.application.credentials.webhooks[:secret], payload)
        head :forbidden unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
      end

      def payload
        @payload ||= request.body.read
      end
    end
  end
end

module Webhooks
  module Github
    class ReposController < ActionController::API
      before_action :verify_signature

      def create
        event = JSON.parse(payload)

        if event['ref'] == 'refs/heads/main'
          commit = event['head_commit']['id']
          name = event['head_commit']['message']
        end

        puts event.inspect

        render head: :ok
      end

      private

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

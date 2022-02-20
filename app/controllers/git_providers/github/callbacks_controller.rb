# frozen_string_literal: true

module GitProviders
  module Github
    class CallbacksController < ApplicationController
      include Omniauthable
      before_action :authenticate!
      skip_verify_authorized

      def index
        github_provider = Current.user.git_providers.github.first
        github_provider.update!(
          access_token: auth_hash.credentials.token,
          refresh_access_token: auth_hash.credentials.refresh_token,
          expires_at: Time.at(auth_hash.credentials.expires_at)
        )
        redirect_to request.env['omniauth.origin']
      end
    end
  end
end

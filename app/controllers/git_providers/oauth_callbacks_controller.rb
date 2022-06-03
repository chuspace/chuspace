# frozen_string_literal: true

module GitProviders
  class OauthCallbacksController < ApplicationController
    include Omniauthable
    before_action :authenticate!
    skip_verify_authorized

    def index
      gitlab_provider = Current.user.git_providers.find_by(name: params[:git_provider_id])

      ActiveRecord::Base.connected_to(role: :writing) do
        gitlab_provider.update!(
          user_access_token: auth_hash.credentials.token,
          app_installation_id: gitlab_provider.app_installation_id || params[:installation_id],
          user_access_token_expires_at: auth_hash.credentials.expires ? Time.at(auth_hash.credentials.expires_at) : nil
        )
      end

      redirect_to request.env['omniauth.origin']
    end
  end
end

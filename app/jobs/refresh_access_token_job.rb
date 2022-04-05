# frozen_string_literal: true

class RefreshAccessTokenJob < ApplicationJob
  def perform(git_provider:)
    api = git_provider.api
    api.endpoint = git_provider.refresh_access_token_endpoint
    response = api.post('',
      {
        refresh_token: git_provider.refresh_access_token,
        grant_type: :refresh_token,
        client_id: Rails.application.credentials.github_app[:client_id],
        client_secret: Rails.application.credentials.github_app[:client_secret]
      }
    )

    git_provider.update!(
      access_token: response.access_token,
      refresh_access_token: response.refresh_access_token || response.refresh_token,
      access_token_expires_at: Time.at(Time.current.to_i + response.expires_in)
    )
  end
end

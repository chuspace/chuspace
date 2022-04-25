

# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  disable_auto_cast!

  attr_config(
    github: {
      label: 'GitHub.com',
      name: :github,
      refresh_access_token_endpoint: 'https://github.com/login/oauth/access_token',
      api_endpoint: 'https://api.github.com',
      access_token_param: :token,
      scopes: 'user,profile,repo,admin:repo_hook',
      client_id: Rails.application.credentials.github_storage[:client_id],
      client_secret: Rails.application.credentials.github_storage[:client_secret]
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.each_with_object({}) do |(key, _), hash|
      hash[key.to_sym] = key
    end
  end
end

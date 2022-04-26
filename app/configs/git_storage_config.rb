

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
      enabled: true,
      scopes: 'user,profile,repo,admin:repo_hook',
      client_id: Rails.application.credentials.github_storage[:client_id],
      client_secret: Rails.application.credentials.github_storage[:client_secret],
      client_options: {
        site: 'https://api.github.com',
        authorize_url: "https://github.com/apps/#{Rails.application.credentials.github_storage[:app_name]}/installations/new",
        token_url: 'https://github.com/login/oauth/access_token'
      }
    },
    github_enterprise: {
      label: 'GitHub Enterprise',
      name: :github_enterprise,
      refresh_access_token_endpoint: '',
      api_endpoint: '',
      access_token_param: :token,
      enabled: false,
      scopes: 'user,profile,repo,admin:repo_hook',
      client_id: '',
      client_secret: '',
      client_options: {}
    },
    gitlab: {
      label: 'GitLab.com',
      name: :gitlab,
      enabled: false,
      refresh_access_token_endpoint: 'https://gitlab.com/oauth/token',
      api_endpoint: 'https://gitlab.com/api/v4',
      access_token_param: 'Bearer',
      scopes: 'api',
      client_id: '',
      client_secret: '',
      client_options: {
        site: 'https://gitlab.com/api/v4',
        authorize_url: "https://gitlab.com/oauth/authorize",
        token_url: 'https://gitlab.com/oauth/token'
      }
    },
    gitlab_foss: {
      label: 'GitLab FOSS',
      name: :gitlab_foss,
      enabled: false,
      refresh_access_token_endpoint: '',
      api_endpoint: '',
      access_token_param: 'Bearer',
      scopes: 'api',
      client_id: '',
      client_secret: '',
      client_options: {}
    },
    gitea: {
      label: 'Gitea.com',
      name: :gitea,
      enabled: false,
      refresh_access_token_endpoint: 'https://gitea.com/login/oauth/access_token',
      api_endpoint: 'https://gitea.com/api/v1',
      access_token_param: :token,
      scopes: '*',
      client_id: '',
      client_secret: '',
      client_options: {
        site: 'https://gitea.com/api/v1',
        authorize_url: "https://gitea.com/login/oauth/authorize",
        token_url: 'https://gitea.com/login/oauth/access_token'
      }
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.each_with_object({}) do |(key, _), hash|
      hash[key.to_sym] = key
    end
  end
end

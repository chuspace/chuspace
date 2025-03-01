

# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  disable_auto_cast!

  attr_config(
    github: {
      label: 'GitHub.com',
      name: :github,
      api_endpoint: 'https://api.github.com',
      user_access_token_param: :token,
      enabled: true,
      scopes: 'user,profile,repo,admin:repo_hook',
      client_id: Rails.application.credentials.github_storage[:client_id],
      client_secret: Rails.application.credentials.github_storage[:client_secret],
      client_options: {
        site: 'https://api.github.com',
        installation_url: "https://github.com/apps/#{Rails.application.credentials.github_storage[:app_name]}/installations/new",
        authorize_url: 'https://github.com/login/oauth/authorize',
        token_url: 'https://github.com/login/oauth/access_token'
      }
    },
    github_enterprise: {
      label: 'GitHub Enterprise',
      name: :github_enterprise,
      api_endpoint: '',
      user_access_token_param: :token,
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
      api_endpoint: 'https://gitlab.com/api/v4',
      user_access_token_param: 'Bearer',
      scopes: 'api',
      client_id: '',
      client_secret: '',
      client_options: {
        site: 'https://gitlab.com/api/v4',
        authorize_url: 'https://gitlab.com/oauth/authorize',
        token_url: 'https://gitlab.com/oauth/token'
      }
    },
    gitlab_foss: {
      label: 'GitLab FOSS',
      name: :gitlab_foss,
      enabled: false,
      api_endpoint: '',
      user_access_token_param: 'Bearer',
      scopes: 'api',
      client_id: '',
      client_secret: '',
      client_options: {}
    },
    gitea: {
      label: 'Gitea.com',
      name: :gitea,
      enabled: false,
      api_endpoint: 'https://gitea.com/api/v1',
      user_access_token_param: :token,
      scopes: '*',
      client_id: '',
      client_secret: '',
      client_options: {
        site: 'https://gitea.com/api/v1',
        authorize_url: 'https://gitea.com/login/oauth/authorize',
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

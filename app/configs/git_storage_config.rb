# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  disable_auto_cast!

  attr_config(
    chuspace: {
      self_hosted: false,
      provider: :chuspace,
      description: 'Chuspace Git storage service for persisting blog repositories.',
      endpoint: 'https://gitea.chuspace.com/api/v1',
      scopes: 'Access token have full access to your account'
    },
    github: {
      self_hosted: false,
      provider: :github,
      endpoint: 'https://api.github.com',
      scopes: 'repo,admin:repo_hook'
    },
    github_enterprise: {
      self_hosted: true,
      provider: :github_enterprise,
      scopes: 'repo,admin:repo_hook'
    },
    gitlab: {
      self_hosted: false,
      provider: :gitlab,
      endpoint: 'https://gitlab.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },
    gitlab_foss: {
      self_hosted: true,
      provider: :gitlab_foss,
      scopes: 'api,read_repository,write_repository'
    },
    gitea: {
      self_hosted: true,
      provider: :gitea,
      scopes: 'Access token have full access to your account'
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.keys.each_with_object({}) do |key, hash|

      hash[key.to_sym] = key
    end
  end

  def self.chuspace
    provider, config = GitStorageConfig.defaults.find { |key, _| key == 'chuspace' }
    config.merge(provider: provider.to_sym).symbolize_keys
  end
end

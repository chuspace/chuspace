# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  attr_config(
    chuspace: {
      label: 'Chuspace.com',
      domain: 'chuspace.dev',
      self_hosted: false,
      description: 'Chuspace Git storage service for persisting blog repositories.',
      endpoint: 'https://gitea.chuspace.com/api/v1',
      scopes: '*'
    },
    github: {
      label: 'Github.com',
      self_hosted: false,
      endpoint: 'https://api.github.com',
      scopes: 'repo,workflow,admin:public_key,admin:repo_hook,delete_repo'
    },
    github_enterprise: {
      label: 'Github enterprise',
      self_hosted: true,
      scopes: 'repo,workflow,admin:public_key,admin:repo_hook,delete_repo'
    },
    gitlab: {
      label: 'Gitlab.com',
      self_hosted: false,
      endpoint: 'https://gitlab.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },
    gitlab_foss: {
      label: 'Gitlab CE/EE',
      self_hosted: true,
      scopes: 'api,read_repository,write_repository'
    },
    gitea: {
      label: 'Gitea',
      self_hosted: true,
      scopes: '*'
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

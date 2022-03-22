# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  disable_auto_cast!

  attr_config(
    github: {
      label: 'GitHub.com',
      provider: :github,
      endpoint: 'https://api.github.com',
      scopes: 'repo,admin:repo_hook'
    },
    gitlab: {
      label: 'GitLab.com',
      provider: :gitlab,
      endpoint: 'https://gitlab.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },
    gitea: {
      label: 'Gitea.com',
      provider: :gitea,
      endpoint: 'https://gitea.com/api/v1',
      scopes: 'api,read_repository,write_repository'
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.each_with_object({}) do |(key, _), hash|
      hash[key.to_sym] = key
    end
  end
end

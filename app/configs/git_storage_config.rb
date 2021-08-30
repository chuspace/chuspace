# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  attr_config(
    github: {
      endpoint: 'https://api.github.com',
      description: 'Git storage provider from Github.com',
      scopes: 'repo,workflow,admin:public_key,admin:repo_hook,delete_repo'
    },

    gitlab: {
      description: 'Git storage provider from Gitlab.com',
      endpoint: 'https://gitlab.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },

    chuspace: {
      description: 'Default git storage hosted by Chuspace on our servers',
      endpoint: 'https://git.chuspace.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },

    bitbucket: {
      description: 'Git storage provider from Bitbucket.com',
      endpoint: 'https://api.github.com',
      scopes: 'repository,repository:write,repository:admin,pullrequest,pullrequest:write,account:write,account'
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

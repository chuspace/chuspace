# frozen_string_literal: true

class GitStorageConfig < ApplicationConfig
  attr_config(
    github: {
      endpoint: 'https://api.github.com',
      scopes: 'repo,workflow,admin:public_key,admin:repo_hook,delete_repo'
    },

    gitlab: {
      endpoint: 'https://gitlab.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },

    chuspace: {
      endpoint: 'https://git.chuspace.com/api/v4',
      scopes: 'api,read_repository,write_repository'
    },

    bitbucket: {
      endpoint: 'https://api.github.com',
      scopes: 'repository,repository:write,repository:admin,pullrequest,pullrequest:write,account:write,account'
    }
  )

  def self.providers_enum
    defaults.keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = key
    end
  end
end

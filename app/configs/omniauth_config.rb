# frozen_string_literal: true

class OmniauthConfig < ApplicationConfig
  attr_config(
    auth: {
      github: {
        label: 'Github',
        id: :github,
        method: :post,
        url: '/auth/github_auth',
        options: {
          name: 'github_auth',
          callback_path: '/auth/github/callback',
          scope: 'user'
        }
      },
      gitlab: {
        label: 'Gitlab',
        id: :gitlab,
        method: :post,
        url: '/auth/gitlab_auth',
        options: {
          name: 'gitlab_auth',
          callback_path: '/auth/gitlab/callback',
          scope: 'read_user email profile'
        }
      },
      bitbucket: {
        label: 'Bitbucket',
        id: :bitbucket,
        method: :post,
        url: '/auth/bitbucket_auth',
        options: {
          name: 'bibucket_auth',
          callback_path: '/auth/bitbucket/callback',
          scope: 'email account'
        }
      }
    },
    storage: {
      github: {
        label: 'Github storage',
        method: :post,
        id: :github,
        url: '/auth/github_storage',
        options: {
          name: 'github_storage',
          setup: true,
          callback_path: '/git_providers/github/callback',
          scope: 'user,profile,repo,admin:repo_hook'
        }
      }
    }
  )

  def self.auth_providers_enum
    @providers_enum ||= defaults['auth'].keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = key
    end
  end

  def self.storage_providers_enum
    @providers_enum ||= defaults['storage'].keys.each_with_object({}) do |key, hash|
      hash[key.to_sym] = key
    end
  end
end

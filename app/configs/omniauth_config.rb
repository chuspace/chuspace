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
      },
      github_enterprise: {
        label: 'Github Enterprise storage',
        method: :post,
        id: :github_enterprise,
        url: '/auth/github_enterprise_storage',
        options: {
          name: 'github_enterprise_storage',
          setup: true,
          callback_path: '/git_providers/github_enterprise/callback',
          scope: 'user,profile,repo,admin:repo_hook'
        }
      },
      gitlab: {
        label: 'Gitlab storage',
        method: :post,
        id: :gitlab,
        url: '/auth/gitlab_storage',
        options: {
          name: 'gitlab_storage',
          setup: true,
          callback_path: '/git_providers/gitlab/callback',
          scope: 'api'
        }
      },
      gitlab_foss: {
        label: 'Gitlab FOSS storage',
        method: :post,
        id: :gitlab_foss,
        url: '/auth/gitlab_foss_storage',
        options: {
          name: 'gitlab_foss_storage',
          setup: true,
          callback_path: '/git_providers/gitlab_foss/callback',
          scope: 'api'
        }
      },
      gitea: {
        label: 'Gitea storage',
        method: :post,
        id: :gitea,
        url: '/auth/gitea_storage',
        options: {
          name: 'gitea_storage',
          setup: true,
          callback_path: '/git_providers/gitea/callback'
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

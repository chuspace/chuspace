# frozen_string_literal: true

class OmniauthConfig < ApplicationConfig
  attr_config(
    github: {
      label: 'Github',
      scope: 'user',
      method: :post,
      url: '/auth/github'
    },
    gitlab: {
      label: 'Gitlab',
      scope: 'read_user email profile',
      method: :post,
      url: '/auth/gitlab'
    },
    bitbucket: {
      label: 'Bitbucket',
      scope: 'email account',
      method: :post,
      url: '/auth/bitbucket'
    },
    gitea: {
      label: 'Gitea',
      scope: 'user',
      method: :post,
      url: '/auth/gitea'
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.keys.each_with_object({}) do |key, hash|

      hash[key.to_sym] = key
    end
  end
end

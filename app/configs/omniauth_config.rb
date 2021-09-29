# frozen_string_literal: true

class OmniauthConfig < ApplicationConfig
  attr_config(
    github: {
      scope: 'user',
      method: :post,
      url: '/auth/github'
    },
    gitlab: {
      scope: 'read_user email profile',
      method: :post,
      url: '/auth/gitlab'
    },
    bitbucket: {
      scope: 'email account',
      method: :post,
      url: '/auth/bitbucket'
    },
    email: {
      scope: '*',
      method: :get,
      url: '/login/email'
    }
  )

  def self.providers_enum
    @providers_enum ||= defaults.keys.each_with_object({}) do |key, hash|

      hash[key.to_sym] = key
    end
  end
end

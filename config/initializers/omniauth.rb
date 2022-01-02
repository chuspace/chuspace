# frozen_string_literal: true

require_relative '../../app/lib/omniauth/strategies/github_app.rb'

Rails.application.config.middleware.use OmniAuth::Builder do
  # Auth oauth
  provider :github,
           Rails.application.credentials.github[:client_id],
           Rails.application.credentials.github[:client_secret],
           scope: OmniauthConfig.new.github[:scope]
  provider :gitlab,
           Rails.application.credentials.gitlab[:client_id],
           Rails.application.credentials.gitlab[:client_secret],
           scope: OmniauthConfig.new.gitlab[:scope]
  provider :bitbucket,
           Rails.application.credentials.bitbucket[:client_id],
           Rails.application.credentials.bitbucket[:client_secret],
           scope: OmniauthConfig.new.bitbucket[:scope]

  # API oauth
  provider OmniAuth::Strategies::GitHub,
           Rails.application.credentials.github_app[:client_id],
           Rails.application.credentials.github_app[:client_secret],
           name: 'github_api',
           callback_path: '/git_providers/github/callback',
           scope: 'user,profile'
  provider OmniAuth::Strategies::GithubApp,
          Rails.application.credentials.github_app[:client_id],
          Rails.application.credentials.github_app[:client_secret],
          name: 'github_app',
          callback_path: '/git_providers/github_app/callback',
          scope: 'user,profile,repo'
  provider OmniAuth::Strategies::GitLab,
           Rails.application.credentials.gitlab_app[:client_id],
           Rails.application.credentials.gitlab_app[:client_secret],
           name: 'gitlab_api',
           callback_path: '/git_providers/gitlab/callback',
           scope: 'api'
end

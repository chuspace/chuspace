# frozen_string_literal: true

gitlab_options = {
  client_options: {
    site: 'https://gitlab.com/api/v4',
    authorize_url: 'https://gitlab.com/oauth/authorize',
    token_url: 'https://gitlab.com/oauth/token'
  }
}

Rails.application.config.middleware.use OmniAuth::Builder do
  # Auth oauth
  provider :github,
           Rails.application.credentials.github[:client_id],
           Rails.application.credentials.github[:client_secret],
           scope: OmniauthConfig.new.github[:scope]
  provider :gitlab,
           Rails.application.credentials.gitlab[:client_id],
           Rails.application.credentials.gitlab[:client_secret],
           scope: OmniauthConfig.new.gitlab[:scope],
           **gitlab_options
  provider :bitbucket,
           Rails.application.credentials.bitbucket[:client_id],
           Rails.application.credentials.bitbucket[:client_secret],
           scope: OmniauthConfig.new.bitbucket[:scope]

  # Git API
  provider OmniAuth::Strategies::GithubApp,
          Rails.application.credentials.github_app[:client_id],
          Rails.application.credentials.github_app[:client_secret],
          name: 'github_app',
          callback_path: '/git_providers/github/callback',
          scope: 'user,profile,repo'
  provider OmniAuth::Strategies::GitLab,
           Rails.application.credentials.gitlab_app[:client_id],
           Rails.application.credentials.gitlab_app[:client_secret],
           name: 'gitlab_app',
           callback_path: '/git_providers/gitlab/callback',
           scope: 'api',
           **gitlab_options
  provider OmniAuth::Strategies::GiteaApp,
          Rails.application.credentials.gitea_app[:client_id],
          Rails.application.credentials.gitea_app[:client_secret],
          name: 'gitea_app',
          callback_path: '/git_providers/gitea/callback'
end

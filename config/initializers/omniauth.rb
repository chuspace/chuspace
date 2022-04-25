# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  # Login oauth
  provider :github,
            Rails.application.credentials.github_auth[:client_id],
            Rails.application.credentials.github_auth[:client_secret],
           **OmniauthConfig.new.auth[:github][:options]
  provider :gitlab,
           Rails.application.credentials.gitlab_auth[:client_id],
           Rails.application.credentials.gitlab_auth[:client_secret],
           **OmniauthConfig.new.auth[:gitlab][:options]
  provider :bitbucket,
           Rails.application.credentials.bitbucket_auth[:client_id],
           Rails.application.credentials.bitbucket_auth[:client_secret],
           **OmniauthConfig.new.auth[:bitbucket][:options]

  # Git storage oauth
  provider OmniAuth::Strategies::Github, **OmniauthConfig.new.storage[:github][:options]
end

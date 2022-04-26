# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Gitea < Github
      option :client_options, {
        site: 'https://gitea.com/api/v1',
        authorize_url: 'https://gitea.com/login/oauth/authorize',
        token_url: 'https://gitea.com/login/oauth/access_token'
      }
    end
  end
end

# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Gitlab < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://gitlab.com/api/v4',
        authorize_url: 'https://gitlab.com/oauth/authorize',
        token_url: 'https://gitlab.com/oauth/token'
      }

      option :redirect_url

      uid { raw_info['id'].to_s }

      info do
        {
          name: raw_info['name'],
          username: raw_info['username'],
          email: raw_info['email'],
          image: raw_info['avatar_url']
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get('user').parsed
      end

      private

      def callback_url
        options.redirect_url || (full_host + script_name + callback_path)
      end
    end
  end
end

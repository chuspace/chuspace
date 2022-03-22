# frozen_string_literal: true

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class GiteaApp < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://gitea.com/api/v1',
        authorize_url: 'https://gitea.com/login/oauth/authorize',
        token_url: 'https://gitea.com/login/oauth/access_token'
      }

      def request_phase
        super
      end

      def authorize_params
        super.tap do |params|
          %w[scope client_options].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end
        end
      end

      uid { raw_info['id'].to_s }

      info do
        {
          'nickname' => raw_info['login'],
          'email' => email,
          'name' => raw_info['name'],
          'image' => raw_info['avatar_url'],
          'urls' => {
            'Gitea' => raw_info['html_url'],
            'Blog' => raw_info['publication'],
          },
        }
      end

      extra do
        { raw_info: raw_info, all_emails: emails, scope: scope }
      end

      def raw_info
        access_token.options[:mode] = :header
        access_token.options[:header_format] = 'token %s'
        puts access_token.token.inspect
        @raw_info ||= access_token.get('user').parsed
      end

      def email
        primary = emails.find { |i| i['primary'] && i['verified'] }
        primary && primary['email'] || nil
      end

      def scope
        access_token['scope']
      end

      def emails
        access_token.options[:mode] = :header
        access_token.options[:header_format] = 'token %s'
        @emails ||= access_token.get('user/emails').parsed
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end

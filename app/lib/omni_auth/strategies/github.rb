# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Github < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: 'https://api.github.com',
        authorize_url: 'https://github.com/login/oauth/authorize',
        token_url: 'https://github.com/login/oauth/access_token'
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
            'GitHub' => raw_info['html_url'],
            'Blog' => raw_info['publication'],
          },
        }
      end

      extra do
        { raw_info: raw_info, all_emails: emails, scope: scope }
      end

      def raw_info
        access_token.options[:mode] = :header
        @raw_info ||= access_token.get('user').parsed
      end

      def email
        primary_email
      end

      def scope
        access_token['scope']
      end

      def primary_email
        primary = emails.find { |i| i['primary'] && i['verified'] }
        primary && primary['email'] || nil
      end

      # The new /user/emails API - http://developer.github.com/v3/users/emails/#future-response
      def emails
        access_token.options[:mode] = :header
        @emails ||= access_token.get('user/emails', headers: { 'Accept' => 'application/vnd.github.v3' }).parsed
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end

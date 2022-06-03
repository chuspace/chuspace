# frozen_string_literal: true

require 'sidekiq/web'

Sidekiq::Web.use(Rack::Auth::Basic) do |username, password|
  username == Rails.application.credentials.sidekiq.dig(:username) &&
    password == Rails.application.credentials.sidekiq.dig(:password)
end

connection_options = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'), ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
connection_options[:password] = ENV['REDIS_AUTH'] if ENV['REDIS_AUTH'].present?

Sidekiq.configure_server do |config|
  config.redis = connection_options
end

Sidekiq.configure_client do |config|
  config.redis = connection_options
end

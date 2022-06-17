# frozen_string_literal: true

Rollbar.configure do |config|
  config.access_token = Rails.application.credentials.rollbar.dig(:access_token)

  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  end

  config.person_username_method = 'username'
  config.custom_data_method = lambda { { region: ENV[:APP_REGION] } }
  config.use_async = true
  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env

  config.branch = 'main'
end

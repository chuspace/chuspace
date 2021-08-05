# frozen_string_literal: true

Sentry.init do |config|
  config.dsn = Rails.application.credentials.sentry[:dsn]
  config.traces_sample_rate = 0.5
end

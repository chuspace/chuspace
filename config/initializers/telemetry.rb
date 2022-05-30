# frozen_string_literal: true

if Rails.env.production?
  require 'opentelemetry/sdk'
  require 'opentelemetry/exporter/otlp'
  require 'opentelemetry/instrumentation/rails'
  require 'opentelemetry/instrumentation/faraday'
  require 'opentelemetry/instrumentation/dalli'
  require 'opentelemetry/instrumentation/pg'
  require 'opentelemetry/instrumentation/active_job'

  OpenTelemetry::SDK.configure do |telemetry|
    telemetry.service_name = ENV.fetch('APP_NAME', 'chuspace')
    telemetry.use_all({ 'OpenTelemetry::Instrumentation::ActionView' => { enabled: false } })
  end
end

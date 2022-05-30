# frozen_string_literal: true

if Rails.env.production?
  require 'opentelemetry/sdk'

  OpenTelemetry::SDK.configure do |telemetry|
    telemetry.use 'OpenTelemetry::Instrumentation::Rails'
    telemetry.use 'OpenTelemetry::Instrumentation::ActionPack'
    telemetry.use 'OpenTelemetry::Instrumentation::ActionView'
    telemetry.use 'OpenTelemetry::Instrumentation::ActiveJob'
    telemetry.use 'OpenTelemetry::Instrumentation::ActiveRecord'
    telemetry.use 'OpenTelemetry::Instrumentation::Faraday'
    telemetry.use 'OpenTelemetry::Instrumentation::Dalli'
    telemetry.use 'OpenTelemetry::Instrumentation::PG'
  end
end

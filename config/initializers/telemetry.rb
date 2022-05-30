# frozen_string_literal: true

if Rails.env.production?
  require 'opentelemetry/sdk'

  OpenTelemetry::SDK.configure do |telemetry|
    telemetry.use_all
  end
end

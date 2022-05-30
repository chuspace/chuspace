
if Rails.env.production?
  require 'opentelemetry/sdk'

  OpenTelemetry::SDK.configure do |telemetry|
    telemetry.use_all
  end
end

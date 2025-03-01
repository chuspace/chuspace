# frozen_string_literal: true

if Rails.env.production?
  Aws::Rails::SqsActiveJob.configure do |config|
    config.logger             = ActiveSupport::Logger.new(STDOUT)
    config.max_messages       = 10
    config.visibility_timeout = 10
    config.shutdown_timeout   = 10
  end
end

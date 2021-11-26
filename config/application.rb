# frozen_string_literal: true

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
# require "action_mailbox/engine"
# require "action_text/engine"
require 'action_view/railtie'
# require 'action_cable/engine'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Chuspace
  class Application < Rails::Application
    # Configure the path for configuration classes that should be used before initialization
    # NOTE: path should be relative to the project root (Rails.root)
    config.anyway_config.autoload_static_config_path = 'app/configs'

    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Customise rails generator
    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
      g.stylesheets false
    end

    config.active_record.encryption.extend_queries = true
    StrongMigrations.start_after = 20211122121358

    # Active Job
    config.active_job.queue_adapter = :good_job
  end
end

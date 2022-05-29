# frozen_string_literal: true

require_relative 'boot'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'active_storage/engine'
require 'rails/test_unit/railtie'
require 'sprockets/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Chuspace
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Customise rails generator
    config.generators do |g|
      g.assets false
      g.helper false
      g.stylesheets false
    end

    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_record.encryption.extend_queries = true
    StrongMigrations.start_after = 20220413144339

    # Active Job
    config.active_job.queue_adapter = :good_job

    # Ziet
    Rails.autoloaders.main.ignore(Rails.root.join('app/packs'))

    # Serve SVG
    config.active_storage.content_types_to_serve_as_binary -= ['image/svg+xml']

    # Setup global redis cache store
    config.cache_store = :mem_cache_store, ENV.fetch('MEMCACHE_URL', 'localhost:11211'), {
      expires_in: 6.hours.to_i,
      namespace: "chuspace-#{Rails.env}-#{ENV['APP_VERSION']}",
      pool_size: 5,
      failover: false,
      pool_timeout: 5
    }

    # Custom error pages
    config.exceptions_app = self.routes

    # Autoload paths
    config.anyway_config.autoload_static_config_path = 'app/configs'
    overrides = "#{root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*.rb").each do |override|
        load override
      end
    end
  end
end

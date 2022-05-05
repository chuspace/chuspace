# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
require 'sprockets/railtie'

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
  end
end

# frozen_string_literal: true

require_relative 'boot'
require 'rails/all'
require 'sprockets/railtie'
require 'graphql/client'
require 'graphql/client/http'

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
    StrongMigrations.start_after = 20211128142958

    # Cache store
    config.cache_store = :redis_cache_store, {
      url: ENV['REDIS_CACHE_SERVERS'].split(','),
      connect_timeout:    30,  # Defaults to 20 seconds
      read_timeout:       0.2, # Defaults to 1 second
      write_timeout:      0.2, # Defaults to 1 second
      reconnect_attempts: 1,   # Defaults to 0

      error_handler: -> (method:, returning:, exception:) {
        # Report errors to Sentry as warnings
        Raven.capture_exception exception, level: 'warning',
          tags: { method: method, returning: returning }
      }
    }

    # Active Job
    config.active_job.queue_adapter = :good_job
  end

  GithubGraphqlHTTPAdapter = GraphQL::Client::HTTP.new('https://api.github.com/graphql') do
    def headers(context)
      unless token = context[:access_token] || Rails.application.credentials.github[:personal_access_token]
        fail 'Missing GitHub access token'
      end

      {
        'Authorization' => "Bearer #{token}",
        'User-Agent' => 'Chuspace'
      }
    end
  end

  Client = GraphQL::Client.new(
    schema: Application.root.join('db/schema.json').to_s,
    execute: GithubGraphqlHTTPAdapter,
  )

  Application.config.graphql_client = ActiveSupport::OrderedOptions.new
  Application.config.graphql_client.github = Client
end

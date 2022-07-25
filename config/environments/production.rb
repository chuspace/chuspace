# frozen_string_literal: true

require 'active_support/core_ext/integer/time'

Aws.config.update(
  region: Rails.application.credentials.dig(:aws, :region),
  credentials: Aws::Credentials.new(Rails.application.credentials.dig(:aws, :access_key_id), Rails.application.credentials.dig(:aws, :secret_access_key))
)

Rails.application.configure do
  # Code is not reloaded between requests.
  config.cache_classes = true
  config.cache_store = :null_store
  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = false

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'Cache-Control' => 'public, s-maxage=31536000, max-age=15552000',
    'Expires' => 1.year.from_now.to_formatted_s(:rfc822)
  }
  # Compress CSS using a preprocessor.
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  config.asset_host = ENV.fetch('ASSET_HOST', 'https://chuspace.com')
  config.action_mailer.default_url_options = { host: 'chuspace.com', protocol: 'https' }
  config.default_url_options = { host: 'chuspace.com' }
  Rails.application.routes.default_url_options[:host] = 'chuspace.com'
  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for Apache
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :amazon

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true
  config.ssl_options = { redirect: { exclude: -> request { /heartbeat/.match?(request.path) } } }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [ :request_id ]

  # Use AWS SES
  config.action_mailer.delivery_method = :ses

  # Use a real queuing backend for Active Job (and separate queues per environment).
  config.active_job.queue_adapter = :amazon_sqs_async
  config.active_job.queue_name_prefix = ''
  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter      = ::Logger::Formatter.new
  config.lograge.enabled    = true
  config.lograge.custom_options = lambda do |event|
    {
      region: ENV.fetch('APP_REGION', 'LOCAL'),
      host: event.payload[:host],
      rails_env: Rails.env,
      process_id: Process.pid,
      request_id: event.payload[:headers]['action_dispatch.request_id'],
      request_time: Time.now,
      remote_ip: event.payload[:remote_ip],
      ip: event.payload[:ip],
      x_forwarded_for: event.payload[:x_forwarded_for],
      params: event.payload[:params].to_json,
      exception: event.payload[:exception]&.first,
      exception_message: "#{event.payload[:exception]&.last}",
      exception_backtrace: event.payload[:exception_object]&.backtrace&.join(',')
    }
  end

  config.lograge.formatter  = Lograge::Formatters::Json.new
  http_device               = Logtail::LogDevices::HTTP.new(Rails.application.credentials.dig(:logtail, :key))
  config.logger             = Logtail::Logger.new(http_device)

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  config.active_record.database_selector = { delay: 2.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

  ActiveSupport::Notifications.subscribe 'database_selector.active_record.read_from_primary' do |name, started, finished, unique_id, data|
    config.logger.info "#{name} Received! (started: #{started}, finished: #{finished}, Duration: #{(finished - started).in_milliseconds}ms)"
  end

  ActiveSupport::Notifications.subscribe 'database_selector.active_record.read_from_replica' do |name, started, finished, unique_id, data|
    config.logger.info "#{name} Received! (started: #{started}, finished: #{finished}, Duration: #{(finished - started).in_milliseconds}ms)"
  end

  # Inserts middleware to perform automatic shard swapping. The `shard_selector` hash
  # can be used to pass options to the `ShardSelector` middleware. The `lock` option is
  # used to determine whether shard swapping should be prohibited for the request.
  #
  # The `shard_resolver` option is used by the middleware to determine which shard
  # to switch to. The application must provide a mechanism for finding the shard name
  # in a proc. See guides for an example.
  # config.active_record.shard_selector = { lock: true }
  # config.active_record.shard_resolver = ->(request) { Tenant.find_by!(host: request.host).shard }
end

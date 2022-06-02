# frozen_string_literal: true

Rails.application.config.session_store :redis_session_store,
  key: '_chuspace_session',
  serializer: :hybrid,
  on_redis_down: ->(exception, env, sid) { Sentry.capture_exception(exception, env) },
  on_session_load_error: ->(e, sid) { Sentry.capture_exception(exception, env) },
  redis: {
    expire_after: 1.week,
    ttl: 1.week,
    key_prefix: "chuspace_#{Rails.env}_session:",
    url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  }

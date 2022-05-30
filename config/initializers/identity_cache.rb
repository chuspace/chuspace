# frozen_string_literal: true

Rails.application.config.identity_cache_store = :mem_cache_store, ENV.fetch('MEMCACHE_URL', 'localhost:11211'), {
  expires_in: 6.hours.to_i,
  namespace: "chuspace-idc-#{Rails.env}-#{ENV['APP_VERSION']}",
  pool_size: 5,
  failover: false,
  pool_timeout: 5
}

IdentityCache.cache_backend = ActiveSupport::Cache.lookup_store(*Rails.configuration.identity_cache_store)

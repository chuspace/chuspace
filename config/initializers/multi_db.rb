# frozen_string_literal: true

Rails.application.configure do
  config.active_record.database_selector = { delay: 1.seconds }
  config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session
end

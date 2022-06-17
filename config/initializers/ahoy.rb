# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false

Ahoy.geocode = false
Ahoy.job_queue = :default
Ahoy.visit_duration = 24.hours
Safely.report_exception_method = ->(exception) { Rollbar.error(exception) }
Ahoy.server_side_visits = :when_needed
Ahoy.cookies = false
Ahoy.mask_ips = true

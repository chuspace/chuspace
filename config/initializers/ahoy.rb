# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false

Ahoy.geocode = false
Ahoy.job_queue = :default
Ahoy.visit_duration = 24.hours
Ahoy.server_side_visits = :when_needed
Ahoy.cookies = false
Ahoy.mask_ips = true

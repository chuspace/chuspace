# frozen_string_literal: true

class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = false

# set to true for geocoding (and add the geocoder gem to your Gemfile)
# we recommend configuring local geocoding as well
# see https://github.com/ankane/ahoy#geocoding
Ahoy.geocode = false
Ahoy.job_queue = :low
Ahoy.visit_duration = 24.hours
Safely.report_exception_method = ->(exception) { Raven::Rack.capture_exception(exception) }
Ahoy.server_side_visits = false

# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  include Rollbar::ActiveJob

  queue_as :default
  retry_on ActiveRecord::Deadlocked
  discard_on ActiveJob::DeserializationError
end

# frozen_string_literal: true

class ApplicationJob < ActiveJob::Base
  queue_as :low
  retry_on ActiveRecord::Deadlocked
  discard_on ActiveJob::DeserializationError
end

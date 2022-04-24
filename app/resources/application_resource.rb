# frozen_string_literal: true

class ApplicationResource
  include Alba::Resource
  delegate :url_helpers, to: 'Rails.application.routes'
end

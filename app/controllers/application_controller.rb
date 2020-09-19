# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include TurbolinksCacheControl
  include SetSentryContext
end

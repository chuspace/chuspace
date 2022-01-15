# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include SetSentryContext
  include ActiveStorage::SetCurrent

  before_action { request.variant.push(:turbo_frame) if turbo_frame_request? }
end

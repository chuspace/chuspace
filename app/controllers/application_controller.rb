# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include SetSentryContext

  before_action :set_paper_trail_whodunnit

  private

  def user_for_paper_trail
    signed_in? ? Current.user.id : 'Public user'
  end
end

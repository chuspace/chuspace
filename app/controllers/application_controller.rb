# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include SetSentryContext
  include Redirectable
  include ActiveStorage::SetCurrent

  after_action :verify_authorized

  delegate :t, to: :I18n

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  etag { Current.identity.try :updated_at }

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.rule}", scope: 'policy', default: :default

    fail ActiveRecord::RecordNotFound
  end

  def current_user
    Current.user
  end
end

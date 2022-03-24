# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include SetSentryContext
  include Redirectable
  include ActiveStorage::SetCurrent

  prepend_before_action :private_beta_stop

  after_action :verify_authorized

  delegate :t, to: :I18n

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  private

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.rule}", scope: 'policy', default: :default

    fail ActiveRecord::RecordNotFound
  end

  def current_user
    Current.user
  end

  def private_beta_stop
    redirect_to root_path, notice: 'We are in private beta!'
  end
end

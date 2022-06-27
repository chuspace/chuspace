# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include Redirectable
  include ActiveStorage::SetCurrent

  after_action :verify_authorized

  delegate :t, to: :I18n

  rescue_from ActionPolicy::Unauthorized, with: :user_not_authorized

  etag { Current.identity.try :updated_at }

  def append_info_to_payload(payload)
    super

    payload[:host] = request.host
    payload[:x_forwarded_for] = request.env['HTTP_X_FORWARDED_FOR']
  end

  private

  def track_ahoy_visit
    MaybeLater.run do
      defer = Ahoy.server_side_visits != true

      ActiveRecord::Base.connected_to(role: :writing) do
        if defer && !Ahoy.cookies
          # avoid calling new_visit?, which triggers a database call
        elsif ahoy.new_visit?
          ahoy.track_visit(defer: defer)
        end
      end
    end
  end

  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore
    flash[:error] = t "#{policy_name}.#{exception.rule}", scope: 'policy', default: :default

    fail ActiveRecord::RecordNotFound
  end

  def current_user
    Current.user
  end
end

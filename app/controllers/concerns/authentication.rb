# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    COOKIE_DOMAINS = %w[chuspace.com]
    before_action :authenticate
  end

  def signin(user)
    cookies.encrypted[:user_id] = {
      value: user.id, expires: 1.year.from_now, domain: COOKIE_DOMAINS, secure: Rails.env.production?
    }

    user.update_tracked_fields!(request)
    user
  end

  def signout
    cookies.delete(:user_id, domain: COOKIE_DOMAINS)
  end

  def signed_in?
    Current.user.present?
  end

  private

  def authenticate
    authenticated_user = User.find_by(id: cookies.encrypted[:user_id])
    signout if authenticated_user.blank?
    Current.user = authenticated_user
  end

  def authenticate!
    redirect_to signins_path unless authenticate
  end
end

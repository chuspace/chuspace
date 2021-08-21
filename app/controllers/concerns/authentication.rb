# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    COOKIE_DOMAINS = %w[chuspace.com]
    before_action :authenticate
    helper_method :signed_in?
  end

  def signin(identity)
    cookies.encrypted[:identity_id] = {
      value: identity.id, expires: 1.year.from_now, domain: COOKIE_DOMAINS, secure: Rails.env.production?
    }

    identity.user.update_tracked_fields!(request)
    authenticate
  end

  def signout
    cookies.delete(:identity_id, domain: COOKIE_DOMAINS)
  end

  def signed_in?
    Current.identity.present? && Current.user.present?
  end

  private

  def authenticate
    identity = Identity.find_by(id: cookies.encrypted[:identity_id])
    signout if identity.blank?

    Current.identity = identity
  end

  def authenticate!
    redirect_to login_path unless authenticate
  end
end

# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    helper_method :signed_in?
  end

  def signin(identity)
    session[:identity_id] = identity.id
    identity.user.update_tracked_fields!(request)
    identity.update(magic_auth_token_expires_at: Time.now)
    identity.regenerate_magic_auth_token

    authenticate
  end

  def signout
    session.clear
  end

  def signed_in?
    Current.identity.present? && Current.user.present?
  end

  private

  def authenticate
    identity = Identity.fetch_by_id(session[:identity_id])
    signout if identity.blank?

    Current.identity = identity
  end

  def authenticate!
    redirect_to sessions_path, notice: 'You need to login again!' unless authenticate
  end
end

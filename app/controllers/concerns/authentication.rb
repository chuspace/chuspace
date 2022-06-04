# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate
    helper_method :signed_in?
  end

  def signin(identity)
    cookies.encrypted[:identity] = {
      value: identity.id, expires: 1.year.from_now, secure: Rails.env.production?
    }

    ActiveRecord::Base.connected_to(role: :writing) do
      identity.user.update_tracked_fields!(request)
      identity.update(magic_auth_token_expires_at: Time.now)
      identity.regenerate_magic_auth_token
    end

    authenticate
  end

  def signout
    cookies.delete(:identity)
  end

  def signed_in?
    Current.identity.present? && Current.user.present?
  end

  private

  def authenticate
    identity = Identity.find_by(id: cookies.encrypted[:identity])
    signout if identity.blank?

    Current.identity = identity
  end

  def authenticate!
    unless signed_in?
      redirect_to sessions_path, notice: 'You need to sign in'
    end
  end
end

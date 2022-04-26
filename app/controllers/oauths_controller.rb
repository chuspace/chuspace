# frozen_string_literal: true

class OauthsController < ApplicationController
  skip_verify_authorized

  include Omniauthable
  include SessionRedirect

  def create
    Identity.transaction do
      identity = Identity.find_by(provider: provider, uid: auth_hash.uid)

      user = if identity.present?
        identity.user
      elsif user = User.find_by(email: auth_hash.info.email)
        existing_provider = user.identities&.first&.provider&.titleize || provider_name
        flash[:notice] = "An account with this email already exists. Please sign in with that account before connecting your #{existing_provider} account."
        redirect_to redirect_location_for(:user) || root_path
        return
      else
        User.create(user_atts)
      end

      if identity.present?
        identity.update(identity_attrs)
      else
        identity = user.identities.create(identity_attrs)
      end

      flash[:notice] = 'Successfully logged in'
      signin(identity) unless signed_in?
    end

    redirect_to redirect_location_for(:user) || root_path
  end

  private

  def identity_attrs
    {
      provider: provider,
      uid: auth_hash.uid
    }.freeze
  end

  def user_atts
    {
      name: auth_hash.info.name,
      email: auth_hash.info.email,
      username: auth_hash.info.username || auth_hash.info.nickname
    }.freeze
  end
end

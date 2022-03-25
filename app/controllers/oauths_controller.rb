# frozen_string_literal: true

class OauthsController < ApplicationController
  skip_verify_authorized
  skip_before_action :private_beta_stop

  include Omniauthable
  include SessionRedirect

  def create
    Identity.transaction do
      identity = Identity.find_by(provider: auth_hash.provider, uid: auth_hash.uid)

      user = if identity.present?
        identity.user
      elsif user = User.find_by(email: auth_hash.info.email)
        existing_provider = user.identities&.first&.provider&.titleize || provider

        if ChuspaceConfig.new.out_of_private_beta
          flash[:notice] = "An account with this email already exists. Please sign in with that account before connecting your #{existing_provider} account."
        else
          flash[:notice] = "Beta invite request already registered through #{existing_provider}. Please wait for an invite!"
        end

        redirect_to redirect_location_for(:user) || root_path
        return
      else
        User.create(user_atts)
      end

      if identity.present?
        flash[:notice] = "Beta invite request already registered through #{provider}. Please wait for an invite!" unless ChuspaceConfig.new.out_of_private_beta
        identity.update(identity_attrs)
      else
        identity = user.identities.create(identity_attrs)

        unless ChuspaceConfig.new.out_of_private_beta
          flash[:notice] = 'Thanks for registering your interest for private beta access 🎉'
          PrivateBetaSignupMailer.with(identity: identity).notify.deliver_later
        end
      end

      if ChuspaceConfig.new.out_of_private_beta
        flash[:notice] = 'Successfully logged in'
        signin(identity) unless signed_in?
      end
    end

    redirect_to redirect_location_for(:user) || root_path
  end

  private

  def identity_attrs
    {
      provider: auth_hash.provider,
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

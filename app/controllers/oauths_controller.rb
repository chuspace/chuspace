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
        redirect_to redirect_location_for(:user) || root_path, notice: t('oauths.create.failure')
        return
      else
        User.create(user_atts)
      end

      if identity.present?
        identity.update(identity_attrs)
      else
        identity = user.identities.create(identity_attrs)
      end

      signin(identity) unless signed_in?
    end

    redirect_to redirect_location_for(:user) || root_path, notice: t('oauths.create.success')
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

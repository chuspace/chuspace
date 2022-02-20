# frozen_string_literal: true

class OauthsController < ApplicationController
  skip_verify_authorized

  include Omniauthable
  attr_reader :identity, :user

  def create
    ApplicationRecord.transaction do
      identity = Identity.where(provider: auth_hash.provider, uid: auth_hash.uid).first
      user = if signed_in?
        Current.user
      elsif identity.present?
        identity.user
      elsif User.where(email: auth_hash.info.email).any?
        flash[:notice] = "An account with this email already exists. Please sign in with that account before connecting your #{provider} account."
        redirect_to sessions_path
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

    flash[:notice] = "Succefully logged in via #{provider}"

    redirect_to root_path
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

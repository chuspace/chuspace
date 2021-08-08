# frozen_string_literal: true

class SessionsController < ApplicationController
  attr_reader :identity, :user

  def new
  end

  def create
    ApplicationRecord.transaction do
      identity = Identity.where(provider: auth_hash.provider, uid: auth_hash.uid).first
      user = set_user

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

  def destroy
    signout
    redirect_to root_path
  end

  private

  def set_user
    if signed_in?
      Current.user
    elsif identity.present?
      identity.user
    elsif User.where(email: auth_hash.info.email).any?
      flash[:notice] = "An account with this email already exists. Please sign in with that account before connecting your #{provider} account."
      User.find_by(email: auth_hash.info.email)
    else
      User.create(name: auth_hash.info.name, username: auth_hash.info.nickname, email: auth_hash.info.email)
    end
  end

  def identity_attrs
    expires_at = auth_hash.credentials.expires_at.present? ? Time.at(auth_hash.credentials.expires_at) : nil
    {
        provider: auth_hash.provider,
        uid: auth_hash.uid,
        expires_at: expires_at,
        access_token: auth_hash.credentials.token,
        access_token_secret: auth_hash.credentials.secret,
    }
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def provider
    auth_hash.provider.titleize
  end
end

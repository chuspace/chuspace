# frozen_string_literal: true

class SessionsController < ApplicationController
  attr_reader :identity, :user

  def new
  end

  def create
    ApplicationRecord.transaction do
      identity = Identity.where(provider: auth_hash.provider, uid: auth_hash.uid).first
      user = find_or_create_user

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

  def find_or_create_user
    if signed_in?
      Current.user
    elsif identity.present?
      identity.user
    elsif User.where(email: auth_hash.info.email).any?
      flash[:notice] = "An account with this email already exists. Please sign in with that account before connecting your #{provider} account."
      User.find_by(email: auth_hash.info.email)
    else
      User.create(user_atts)
    end
  end

  def identity_attrs
    {
      provider: auth_hash.provider,
      uid: auth_hash.uid
    }.freeze
  end

  def user_atts
    {
      name: auth_hash.info.name,
      email: auth_hash.info.email
    }.freeze
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def provider
    auth_hash.provider.titleize
  end
end

# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    puts auth_hash.inspect

    @user =
      User.find_or_create_by(provider: auth_hash['provider'], uid: auth_hash['uid']).tap do |user|
        user.provider_token = auth_hash['credentials']['token']
        user.provider_secret = auth_hash['credentials']['secret']
      end

    login(@user)

    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

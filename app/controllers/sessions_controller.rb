# frozen_string_literal: true

class SessionsController < ApplicationController
  def create
    @user =
      User.find_or_initialize_by(provider: auth_hash['provider'], uid: auth_hash['uid']).tap do |user|
        user.token = auth_hash['credentials']['token']
        user.name = auth_hash['info']['name']
        user.email = auth_hash['info']['email']
        user.username = auth_hash['info']['nickname']
      end

    @user.set_tracked_fields(request)

    if @user.save
      signin(@user)
    end

    redirect_to root_path
  end

  def destroy
    signout
    redirect_to root_path
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end

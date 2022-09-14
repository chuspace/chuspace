# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_verify_authorized

  include SessionRedirect
  layout 'marketing'

  def email
    @user = User.new(email: params[:email])
  end

  def create
    @identity = Identity.find_by(provider: :email, uid: session_params[:email])

    @identity.send_magic_auth_email! if @identity.present?
    redirect_to redirect_location_for(:user) || root_path, notice: t('sessions.create.confirm')
  end

  def destroy
    signout
    redirect_to root_path, notice: t('sessions.destroy.success')
  end

  private

  def session_params
    params.require(:user).permit(:email)
  end
end

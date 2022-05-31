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

    if @identity
      @identity.send_magic_auth_email!
      redirect_to redirect_location_for(:user) || root_path, notice: t('sessions.create.success')
    else
      @user = User.new(email: session_params[:email])

      if user = User.find_by(email: session_params[:email])
        @user.errors.add(:email, :identity_taken, provider: user.identities.pluck(:provider).to_sentence)
      else
        @user.errors.add(:email, :no_email_identity)
      end

      respond_to do |format|
        format.html { redirect_to email_sessions_path, error: t('sessions.create.failure') }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user, partial: 'sessions/form', locals: { user: @user }) }
      end
    end
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

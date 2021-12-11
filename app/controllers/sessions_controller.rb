# frozen_string_literal: true

class SessionsController < ApplicationController
  layout 'marketing'
  include SessionRedirect

  def index
  end

  def email
    @user = User.new
  end

  def create
    @identity = Identity.find_by(provider: :email, uid: session_params[:email])

    if @identity
      @identity.send_magic_auth_email!
      redirect_to root_path, notice: t('.success')
    else
      @user = User.new(email: session_params[:email])
      @user.errors.add(:email, 'Email not found')

      respond_to do |format|
        format.html { render :email }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user, partial: 'sessions/form', locals: { user: @user }) }
      end
    end
  end

  def destroy
    signout
    redirect_to root_path
  end

  private

  def session_params
    params.require(:user).permit(:email)
  end
end

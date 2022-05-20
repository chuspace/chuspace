# frozen_string_literal: true

class SignupsController < ApplicationController
  skip_verify_authorized
  include SessionRedirect

  layout 'marketing'

  def email
    @user = User.new(email: params[:email])
  end

  def create
    @user = User.build_with_email_identity(signup_params)

    if @user.save
      redirect_to redirect_location_for(:user) || signups_path, notice: t('.success')
    else
      respond_to do |format|
        format.html { redirect_to email_signups_path, notice: t('.failure') }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@user, partial: 'signups/form', locals: { user: @user }) }
      end
    end
  end

  private

  def signup_params
    params.require(:user).permit(:username, :email, :name)
  end
end

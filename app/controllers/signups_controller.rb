# frozen_string_literal: true

class SignupsController < ApplicationController
  include SessionRedirect

  def email
    @user = User.new
  end

  def create
    @user = User.create_with_email_identity(email: signup_params[:email])

    if @user.save
      redirect_to signups_path, notice: t('.success')
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

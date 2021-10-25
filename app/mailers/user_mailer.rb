# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def email_welcome
    @identity = params[:identity]
    @user = @identity.user
    @subject = t('.subject', name: @user.name)
    mail(to: @user.email, subject: @subject)
  end

  def send_magic_login
    @identity = params[:identity]
    @user = @identity.user
    @subject = t('.subject', name: @user.name)
    mail(to: @user.email, subject: @subject)
  end
end

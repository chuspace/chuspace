# frozen_string_literal: true

class PrivateBetaSignupMailer < ApplicationMailer
  def notify
    @identity = params[:identity]
    @user = @identity.user

    @subject = t('.subject', name: @user.name)
    mail(to: @user.email, subject: @subject)
  end
end

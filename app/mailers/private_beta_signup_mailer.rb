# frozen_string_literal: true

class PrivateBetaSignupMailer < ApplicationMailer
  RECIPIENT = 'signups@chuspace.com'

  def notify
    @identity = params[:identity]
    @user = @identity.user

    @subject = t('.subject', name: @user.name)
    mail(to: RECIPIENT, subject: @subject)
  end
end

# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome_email
    @user     = params[:user]
    @identity = @user.identities.email.first
    @subject  = t('.subject', name: @user.name)

    mail(to: @user.email, subject: @subject)
  end

  def magic_login_email
    @identity = params[:identity]
    @user     = @identity.user
    @subject  = t('.subject', name: @user.name)

    mail(to: @user.email, subject: @subject)
  end

  def invite_email
    @invite       = params[:invitation]
    @sender       = @invite.sender
    @publication  = @invite.publication
    @subject      = t('.subject', person: @sender.name, publication: @publication.name)

    mail(to: @invite.recipient_email, subject: @subject)
  end
end

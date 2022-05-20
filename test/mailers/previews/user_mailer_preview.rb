class UserMailerPreview < ActionMailer::Preview
  def welcome_email
    UserMailer.with(identity: Identity.first).welcome_email
  end

  def magic_login_email
    UserMailer.with(identity: Identity.first).magic_login_email
  end

  def invite_email
    invite = Invite.new(sender: User.first, identifier: User.first.email, publication: Publication.new(name: 'Foo', permalink: 'foo'))
    UserMailer.with(invitation: invite).invite_email
  end
end

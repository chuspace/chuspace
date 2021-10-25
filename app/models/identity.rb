# frozen_string_literal: true

class Identity < ApplicationRecord
  MAGIC_AUTH_TOKEN_LIFE = 30
  has_secure_token :magic_auth_token
  belongs_to :user

  encrypts :uid, deterministic: true, downcase: true
  enum provider: OmniauthConfig.providers_enum.merge(email: 'email')

  after_create_commit :send_access_email, if: :email?

  def magic_auth_token_valid?
    magic_auth_token_expires_at.to_i >= Time.now.to_i
  end

  def send_magic_auth_email!
    regenerate_magic_auth_token
    update(magic_auth_token_expires_at: MAGIC_AUTH_TOKEN_LIFE.minutes.from_now)

    UserMailer.with(identity: self).send_magic_login.deliver_later
  end

  private

  def send_access_email
    UserMailer.with(identity: self).email_welcome.deliver_later
  end
end

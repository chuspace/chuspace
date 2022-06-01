# frozen_string_literal: true

class Identity < ApplicationRecord
  MAGIC_AUTH_TOKEN_LIFE = 30

  has_secure_token :magic_auth_token

  belongs_to :user, touch: true

  encrypts :uid, deterministic: true, downcase: true

  enum provider: OmniauthConfig.auth_providers_enum.merge(email: 'email')

  before_validation     :set_magic_auth_token_expires_at, if: :email?
  validates_presence_of :magic_auth_token_expires_at, if: :email?

  def magic_auth_token_valid?
    magic_auth_token_expires_at.to_i >= Time.current.to_i
  end

  def send_magic_auth_email!
    regenerate_magic_auth_token
    update(magic_auth_token_expires_at: Time.current + MAGIC_AUTH_TOKEN_LIFE.minutes)

    UserMailer.with(identity: self).magic_login_email.deliver_later
  end

  private

  def set_magic_auth_token_expires_at
    self.magic_auth_token_expires_at = Time.current + MAGIC_AUTH_TOKEN_LIFE.minutes
  end
end

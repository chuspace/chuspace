# frozen_string_literal: true

module TestSessionHelper
  extend ActiveSupport::Concern

  def signin(identity:)
    get magic_logins_path, params: { token: identity.magic_auth_token }
  end

  def signout(identity:)
    delete magic_login_path, params: { id: identity.id }
  end
end

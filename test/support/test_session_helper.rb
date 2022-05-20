# frozen_string_literal: true

module TestSessionHelper
  extend ActiveSupport::Concern

  def signin(identity:)
    cookies_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    cookies_jar.encrypted[:identity_id] = { value: identity.id }
    cookies[:identity_id] = cookies_jar[:identity_id]
  end

  def signout
    cookies.delete(:identity_id)
  end
end

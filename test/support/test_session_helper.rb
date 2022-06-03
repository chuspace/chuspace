# frozen_string_literal: true

module TestSessionHelper
  extend ActiveSupport::Concern

  def signin(identity:)
    cookies_jar = ActionDispatch::Request.new(Rails.application.env_config.deep_dup).cookie_jar
    cookies_jar.encrypted[:identity] = { value: identity.id }
    cookies[:identity] = cookies_jar[:identity]
  end

  def signout
    cookies.delete(:identity)
  end
end

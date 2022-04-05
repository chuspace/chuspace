# frozen_string_literal: true

module Omniauthable
  extend ActiveSupport::Concern

  def auth_hash
    request.env['omniauth.auth']
  end

  def provider_name
    provider.titleize
  end

  def provider
    auth_hash.provider.split('_', 2).first
  end
end

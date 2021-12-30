module Omniauthable
  extend ActiveSupport::Concern

  def auth_hash
    request.env['omniauth.auth']
  end

  def provider
    auth_hash.provider.titleize
  end
end

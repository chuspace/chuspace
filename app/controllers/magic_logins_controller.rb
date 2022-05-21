# frozen_string_literal: true

class MagicLoginsController < ApplicationController
  skip_verify_authorized

  include SessionRedirect

  def index
    identity = Identity.find_by(magic_auth_token: params[:token])

    if identity&.magic_auth_token_valid?
      signin(identity)
      redirect_to root_url, notice: t('magic_logins.index.success')
    else
      redirect_to sessions_url, notice: t('magic_logins.index.expired')
    end
  end
end

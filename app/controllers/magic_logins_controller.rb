# frozen_string_literal: true

class MagicLoginsController < ApplicationController
  before_action :redirect_if_signedin, if: :signed_in?

  def index
    identity = Identity.find_by(magic_auth_token: params[:token])

    if identity&.magic_auth_token_valid?
      signin(identity)
      redirect_to root_url, notice: t('.success')
    else
      redirect_to sessions_url, notice: t('.expired')
    end
  end

  private

  def redirect_if_signedin
    redirect_to(root_path, notice: t('sessions.already_signedin')) && return
  end
end

# frozen_string_literal: true

module SessionRedirect
  extend ActiveSupport::Concern

  included do
    before_action :redirect_if_signedin, if: :signed_in?, except: :destroy
  end

  def redirect_if_signedin
    redirect_to(redirect_location_for(:user) || root_path, notice: t('sessions.already_signedin')) && return
  end
end

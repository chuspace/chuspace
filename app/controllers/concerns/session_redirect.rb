module SessionRedirect
  extend ActiveSupport::Concern

  included do
    before_action :redirect_if_signedin, if: :signed_in?, except: :destroy
  end

  def redirect_if_signedin
    redirect_to(root_path, notice: t('sessions.already_signedin')) && return
  end
end

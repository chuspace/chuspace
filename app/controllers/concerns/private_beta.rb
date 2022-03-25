module PrivateBeta
  extend ActiveSupport::Concern

  included do
    before_action :private_beta_stop, unless: -> { ChuspaceConfig.new.out_of_private_beta }
  end

  private

  def private_beta_stop
    redirect_to root_path, notice: t('shared.private_beta')
  end
end

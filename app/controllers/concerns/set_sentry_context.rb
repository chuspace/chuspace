# frozen_string_literal: true

module SetSentryContext
  extend ActiveSupport::Concern

  included { before_action :set_raven_context }

  private

  def set_raven_context
    Raven.user_context(id: Current.user&.id)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end

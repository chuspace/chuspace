# frozen_string_literal: true

module SetSentryContext
  extend ActiveSupport::Concern

  included { before_action :set_sentry_context }

  private

  def set_sentry_context
    Sentry.set_user(id: Current.user&.id)
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end
end

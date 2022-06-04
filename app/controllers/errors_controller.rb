# frozen_string_literal: true

class ErrorsController < ApplicationController
  skip_verify_authorized

  def not_found
    render(status: 404)
  end

  def internal_server_error
    exception = request.env['action_dispatch.exception']
    Sentry.capture_exception(exception) if exception
    render(status: 500)
  end

  def unprocessible_entity
    render(status: 422)
  end

  def unacceptable
    render(status: 406)
  end
end

class WebhooksController < ApplicationController
  protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token

  def create
    body = request.body.read
    event = JSON.parse(body)

    puts event.inspect

    render html: 'OK'
  end
end

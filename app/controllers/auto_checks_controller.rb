# frozen_string_literal: true

class AutoChecksController < ApplicationController
  skip_verify_authorized

  def create
    attribute = params[:attribute]

    case attribute
    when 'email', 'username'
      perform_check(resource: User, attribute: attribute)
    else
      head :ok
    end
  end

  private

  def perform_check(resource:, attribute:)
    record = resource.new("#{attribute}": params[:value])

    if record.valid_attributes?(attribute)
      head :ok
    else
      render html: record.errors.messages_for(attribute.to_sym).uniq.to_sentence.html_safe, status: :unprocessable_entity
    end
  end
end

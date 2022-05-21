# frozen_string_literal: true

class AutoChecksController < ApplicationController
  skip_verify_authorized

  def create
    attribute = params[:attribute]

    case params[:type]
    when 'auth'
      if %w[email username].include?(attribute) && params[:value]
        user = User.joins(:email_identities).find_or_initialize_by("#{attribute}": params[:value])

        unless user.persisted?
          user.errors.add(:email, 'Not found')
          render html: user.errors.messages_for(attribute.to_sym).uniq.to_sentence.html_safe, status: :unprocessable_entity
        else
          head :ok
        end
      else
        head :ok
      end
    when nil
      case attribute
      when 'email', 'username'
        perform_check(resource: User, attribute: attribute)
      end
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

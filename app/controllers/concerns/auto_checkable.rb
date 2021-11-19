# frozen_string_literal: true

module AutoCheckable
  extend ActiveSupport::Concern

  def check_resource_available(resource:, attribute:)
    if resource.valid_attributes?(attribute)
      head :ok
    else
      render html: resource.errors.messages[attribute.to_sym].to_sentence.html_safe, status: :unprocessable_entity
    end
  end
end

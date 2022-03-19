# frozen_string_literal: true

class ApplicationComponent < ViewComponent::Base
  include ViewComponent::Translatable, ActiveModel::Validations
end

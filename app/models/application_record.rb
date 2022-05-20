# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def valid_attributes?(*attributes)
    errors.clear

    attributes.each do |attribute|
      self.class.validators_on(attribute).each { |validator| validator.validate_each(self, attribute, send(attribute)) }
    end

    errors.empty?
  end
end

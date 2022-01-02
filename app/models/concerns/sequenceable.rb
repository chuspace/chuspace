# frozen_string_literal: true

module Sequenceable
  extend ActiveSupport::Concern

  included do
    self.implicit_order_column = 'number'
    before_validation :assign_next_number_sequence, on: :create
  end

  class_methods do
    def current
      last
    end
  end

  private

  def assign_next_number_sequence
    self.number = if post.persisted?
      items = post.send(self.class.name.pluralize.downcase)
      items.current ? items.current.number.to_i + 1 : 1
    else
      1
    end
  end
end

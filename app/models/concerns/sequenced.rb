# frozen_string_literal: true

module Sequenced
  extend ActiveSupport::Concern

  included do
    validates :number, uniqueness: { scope: :post_id }
    before_validation :assign_next_number_sequence, on: :create
    self.implicit_order_column = 'number'
  end

  private

  def assign_next_number_sequence
    self.number = post.send(self.class.table_name).last&.number.to_i + 1
  end
end

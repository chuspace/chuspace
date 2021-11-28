# frozen_string_literal: true

class Edition < ApplicationRecord
  extend FriendlyId

  friendly_id :title, use: %i[slugged history], slug_column: :permalink

  belongs_to :publisher, class_name: 'User'
  belongs_to :revision
  belongs_to :blog

  delegate :post, to: :revision

  acts_as_taggable_on :topics

  validates :number, uniqueness: { scope: :revision_id }
  before_validation :assign_next_number_sequence, on: :create

  class << self
    alias current first
  end

  private

  def assign_next_number_sequence
    self.number = post.editions.current&.number.to_i + 1
  end
end

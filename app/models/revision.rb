# frozen_string_literal: true

class Revision < ApplicationRecord
  belongs_to :publication
  belongs_to :post
  belongs_to :author, class_name: 'User'

  enum state: ChuspaceConfig.new.revision[:states]

  before_validation :assign_next_number, on: :create

  def to_param
    "revision##{number}"
  end

  private

  def assign_next_number
    self.number = (post.revisions.maximum(:number) || 0) + 1
  end
end

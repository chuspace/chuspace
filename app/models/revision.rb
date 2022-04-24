# frozen_string_literal: true

class Revision < ApplicationRecord
  extend FriendlyId

  belongs_to :publication
  belongs_to :post
  belongs_to :author, class_name: 'User'

  enum status: ChuspaceConfig.new.revision[:statuses]

  before_validation :assign_next_number, on: :create

  friendly_id :identifier, use: %i[slugged history scoped], slug_column: :permalink, scope: %i[publication post]

  def identifier
    "revision##{number}"
  end

  private

  def assign_next_number
    self.number = (post.revisions.maximum(:number) || 0) + 1
    self.status = ChuspaceConfig.new.revision[:default_status]
  end
end

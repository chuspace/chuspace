# frozen_string_literal: true

class Revision < ApplicationRecord
  include Sequenced, Markdownable

  belongs_to :draft
  belongs_to :author, class_name: 'User', optional: true
  has_one    :edition, dependent: :destroy, inverse_of: :revision
end

# frozen_string_literal: true

class Revision < ApplicationRecord
  include Immutable, Commitable, Sourceable, Sequenceable, Markdownable

  belongs_to :post, touch: true
  belongs_to :committer, class_name: 'User', optional: true, touch: true
  has_one    :edition, dependent: :destroy, inverse_of: :revision

  delegate :author, :blog, to: :post

  validates :number, presence: true, uniqueness: { scope: :post_id }
  validates :fallback_committer, presence: true, unless: :committer

  def to_param
    sha
  end
end

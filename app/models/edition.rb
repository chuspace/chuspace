# frozen_string_literal: true

class Edition < ApplicationRecord
  include Sequenced
  extend FriendlyId

  friendly_id :title, use: %i[slugged history], slug_column: :permalink

  belongs_to :publisher, class_name: 'User'
  belongs_to :revision
  belongs_to :blog

  delegate :post, to: :revision

  acts_as_taggable_on :topics

  class << self
    alias current first
  end
end

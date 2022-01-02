# frozen_string_literal: true

class Edition < ApplicationRecord
  include Sequenceable, Markdownable
  extend FriendlyId

  friendly_id :title, use: %i[slugged history], slug_column: :permalink

  belongs_to :publisher, class_name: 'User'
  belongs_to :revision

  delegate :post, :blog, :content, to: :revision

  acts_as_taggable_on :topics

  validates :number, uniqueness: { scope: :revision_id }
end

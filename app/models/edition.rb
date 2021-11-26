# frozen_string_literal: true

class Edition < ApplicationRecord
  include Sequenced, Markdownable

  belongs_to :publisher, class_name: 'User'
  belongs_to :revision
  belongs_to :blog

  delegate :content, to: :revision

  acts_as_taggable_on :topics
end

# frozen_string_literal: true

class Template < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :storage
  before_validation :set_permalink

  private

  def set_permalink
    self.permalink = name.to_slug.normalize.to_s
  end
end

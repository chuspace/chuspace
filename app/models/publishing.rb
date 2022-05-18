# frozen_string_literal: true

class Publishing < ApplicationRecord
  belongs_to :post
  belongs_to :author, class_name: 'User'

  validates :commit_sha, presence: true

  def short_commit_sha
    commit_sha.first(7)
  end
end

# frozen_string_literal: true

class EditingLock < ApplicationRecord
  DEFAULT_EXPIRES_AT = 1.hour.from_now

  belongs_to :publication
  belongs_to :owner, class_name: 'User'

  validates :blob_path, uniqueness: { scope: :publication_id }
  validate :owner_must_be_part_of_publication

  private

  def owner_must_be_part_of_publication
    errors.add(:owner, 'Lock can only be acquired by editors') unless publication.memberships.editors.where(user: owner).exists?
  end
end

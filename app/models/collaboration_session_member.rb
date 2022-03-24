# frozen_string_literal: true

class CollaborationSessionMember < ApplicationRecord
  belongs_to :collaboration_session
  belongs_to :user

  validate  :validate_publication_membership_status
  validates :collaboration_session_id, uniqueness: { scope: :user_id }

  before_create :set_online

  delegate :publication, to: :collaboration_session

  private

  def validate_publication_membership_status
    errors.add(:user, 'not allowed to collaborate') unless publication.memberships.writers.exists?(user: user)
  end

  def set_online
    self.online = true
    self.last_seen_at = Time.current
  end
end

# frozen_string_literal: true

class CollaborationSessionMember < ApplicationRecord
  belongs_to :collaboration_session
  belongs_to :user

  validate  :validate_publication_membership_status
  validates :collaboration_session_id, uniqueness: { scope: :user_id }

  before_create :set_online
  after_create_commit :append_member
  after_update_commit :replace_member
  after_destroy_commit :remove_member

  delegate :publication, to: :collaboration_session

  def self.default_scope
    order(:id)
  end

  private

  def validate_publication_membership_status
    errors.add(:user, 'not allowed to collaborate') unless publication.memberships.writers.exists?(user: user)
  end

  def set_online
    self.online = true
    self.last_seen_at = Time.current
  end

  def append_member
    broadcast_append_later_to collaboration_session, :collaborators, partial: 'publications/drafts/collaborator', locals: { member: self }
  end

  def replace_member
    broadcast_replace_later_to collaboration_session, :collaborators, partial: 'publications/drafts/collaborator', locals: { member: self }
  end

  def remove_member
    broadcast_remove_to collaboration_session, :collaborators
  end
end

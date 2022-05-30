# frozen_string_literal: true

class ServerSideSession < ActiveRecord::SessionStore::Session
  ACTIVE_SESSION_LIMIT = 100

  belongs_to :identity, optional: true

  before_save :set_identity_id

  scope :by_oldest, -> { order(updated_at: :asc) }
  after_commit :trim_active_sessions

  private

  def trim_active_sessions
    ServerSideSession
      .offset(ACTIVE_SESSION_LIMIT)
      .where(identity_id: identity_id)
      .by_oldest
      .delete_all
  end

  def set_identity_id
    self.identity_id = data['identity_id']
  end
end

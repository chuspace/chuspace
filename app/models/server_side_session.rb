# frozen_string_literal: true

class ServerSideSession < ActiveRecord::SessionStore::Session
  ACTIVE_SESSION_LIMIT = 100
  include IdentityCache

  belongs_to :identity, optional: true

  cache_index :session_id, unique: true

  before_save :set_identity_id

  scope :by_oldest, -> { order(:id) }
  after_commit :trim_active_sessions

  def self.find_by_session_id(session_id)
    IdentityCache.with_fetch_read_only_records(false) do
      fetch_by_session_id(session_id)
    end
  end

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

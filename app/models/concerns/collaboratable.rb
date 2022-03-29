# frozen_string_literal: true

module Collaboratable
  extend ActiveSupport::Concern

  def find_or_start_collaboration_session(user:, blob_path:)
    CollaborationSession.transaction do
      collaboration_session = collaboration_sessions.active.find_or_initialize_by(blob_path: blob_path) do |session|
        session.members.build(user: user, creator: true)
        session.initial_ydoc = $ydoc.compile(content: draft(path: blob_path).decoded_content, username: user.username)
        session.save!
      end

      collaboration_session.members.create(user: user) unless collaboration_session.members.exists?(user: user)
      collaboration_session
    end
  end

  def end_collaboration_session(blob_path:)
    collaboration_sessions.where(blob_path: blob_path).update_all(active: false)
  end
end

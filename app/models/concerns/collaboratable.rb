module Collaboratable
  extend ActiveSupport::Concern

  def find_or_start_collaboration_session(user:, blob_path:)
    CollaborationSession.transaction do
      collaboration_session = collaboration_sessions.find_or_initialize_by(blob_path: blob_path) do |session|
        session.members.build(user: user, creator: true)
        session.initial_ydoc = $ydoc.compile(markdown: draft(path: blob_path).decoded_content, username: user.username)
        session.save!
      end

      collaboration_session.members.create(user: user) unless collaboration_session.members.exists?(user: user)
      collaboration_session
    end
  end

  def end_collaboration_session(user:, blob_path:)
    collaboration_sessions.where(user: user, blob_path: blob_path).destroy_all
  end
end

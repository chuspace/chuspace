# frozen_string_literal: true

class CollaborationSessionChannel < ApplicationCable::Channel
  def subscribed
    if stream_name = verified_stream_name
      collaboration_session = CollaborationSession.open.find(stream_name)
      authorize! collaboration_session, to: :update?
      member = collaboration_session.members.find_by(user: current_user)
      member.update(online: true, last_seen_at: Time.current)

      stream_from "collaboration_session:#{stream_name}"
    else
      reject
    end
  end

  def receive(params)
    ActionCable.server.broadcast("collaboration_session:#{verified_stream_name}", params)
  end

  def unsubscribed
    stop_all_streams
    collaboration_session = CollaborationSession.open.find(verified_stream_name)
    authorize! collaboration_session, to: :update?
    member = collaboration_session.members.find_by(user: current_user)
    member.update(online: false, last_seen_at: Time.current)
  end

  private

  def verified_stream_name
    Turbo.signed_stream_verifier.verified(params['id'])
  end
end

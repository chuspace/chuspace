# frozen_string_literal: true

class CollabChannel < ApplicationCable::Channel
  def subscribed
    if stream_name = verified_stream_name
      _, publication_permalink, draft_path = stream_name.split(':', 3)
      publication = current_user.publications.friendly.find(publication_permalink)
      draft = publication.draft(path: draft_path)
      draft.collaboration_leader_id.value ||= current_user.id
      draft.collaborators_ids.append(current_user.id)
      authorize! draft, to: :edit?

      stream_from stream_name
    else
      reject
    end
  end

  def receive(params)
    ActionCable.server.broadcast(verified_stream_name, params)
  end

  def unsubscribed
    stop_all_streams
    _, publication_permalink, draft_path = verified_stream_name.split(':', 3)
    publication = current_user.publications.friendly.find(publication_permalink)
    draft = publication.draft(path: draft_path)

    draft.collaborators_ids.remove(current_user.id)
  end

  private

  def verified_stream_name
    Turbo.signed_stream_verifier.verified(params['id'])
  end
end

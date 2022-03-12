class CollabChannel < ApplicationCable::Channel
  def subscribed
    publication_permalink, draft_name = params['id'].split(':', 2)
    publication = current_user.publications.friendly.find(publication_permalink)
    draft = publication.draft(path: publication.draft_path_for(name: draft_name))

    stream_from "collab_#{publication_permalink}_#{draft_name}"

    ActionCable.server.broadcast("collab_#{publication_permalink}_#{draft_name}", {
      id: params['id'],
      initial: true,
      message: draft.decoded_content
    })
  end

  def receive(params)
    publication_permalink, draft_name = params['id'].split(':', 2)
    publication = current_user.publications.friendly.find(publication_permalink)
    draft = publication.draft(path: publication.draft_path_for(name: draft_name))

    ActionCable.server.broadcast("collab_#{publication_permalink}_#{draft_name}", params)
  end

  def unsubscribed
    stop_all_streams
  end
end

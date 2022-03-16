class CollabChannel < ApplicationCable::Channel
  def subscribed
    publication_permalink, draft_path = params['id'].split(':', 2)
    stream_from "collab_#{publication_permalink}:#{draft_path}"
  end

  def receive(params)
    publication_permalink, draft_path = params['id'].split(':', 2)
    ActionCable.server.broadcast("collab_#{publication_permalink}:#{draft_path}", params)
  end

  def unsubscribed
    stop_all_streams
  end
end

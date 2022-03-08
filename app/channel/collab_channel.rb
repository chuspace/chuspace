class CollabChannel < ApplicationCable::Channel
  def subscribed
    stream_from "collab"
  end

  def receive(params)
    ActionCable.server.broadcast("collab", params)
  end

  def unsubscribed
    stop_all_streams
  end
end

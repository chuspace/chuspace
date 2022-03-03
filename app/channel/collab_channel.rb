class CollabChannel < ApplicationCable::Channel
  def subscribed
    stream_from "collab"
  end

  def receive(params)
    puts params['data'].pack('C*').force_encoding('UTF-8')
    ActionCable.server.broadcast("collab", params)
  end

  def unsubscribed
    stop_all_streams
  end
end

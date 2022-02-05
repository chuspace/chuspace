# frozen_string_literal: true

class AutosaveChannel < ApplicationCable::Channel
  def subscribed
    publication = Publication.friendly.find(params[:publication_permalink])
    draft = publication.draft(path: params[:path])

    stream_from "#{publication.permalink}:draft:#{draft.path}"
  end

  def receive(data)
    publication = Publication.friendly.find(params[:publication_permalink])
    draft = publication.draft(path: params[:path])
    draft.local_content.value = data['body']
    draft.stale.value = true

    ActionCable.server.broadcast("#{publication.permalink}:draft:#{draft.path}", { success: true }.to_json)
  end

  def unsubscribed
    stop_all_streams
  end
end

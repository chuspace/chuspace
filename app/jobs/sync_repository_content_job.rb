# frozen_string_literal: true

class SyncRepositoryContentJob < ApplicationJob
  queue_as :default

  def perform(repository:)
    Blob.transaction do
      repository.blobs.delete_all
      repository.git_blobs.each do |git_blob|
        blob = repository.blobs.new(name: git_blob.name, path: git_blob.path, sha: git_blob.sha || git_blob.id)
        io = StringIO.new(Base64.decode64(git_blob.content))
        mime = Marcel::MimeType.for name: git_blob.name

        blob.content.attach(io: io, filename: git_blob.name, content_type: mime)
        blob.save!
      end
    end
  end
end

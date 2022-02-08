# frozen_string_literal: true

module Git
  class Commit < ActiveType::Object
    class NotAllowedError < StandardError; end

    attribute :id, :string
    attribute :message, :string
    attribute :patch, :string
    attribute :committed_at, :datetime
    attribute :committer, Git::Committer.new
    attribute :author, Git::Author.new
    attribute :adapter, ApplicationAdapter

    validates :message, :author, :committer, :adapter, presence: true

    def full
      @full ||= adapter.commit(sha: id)
    end

    def create_for!(blob:)
      fail NotAllowedError, 'Can not recommit' if persisted?

      blob = adapter.create_or_update_blob(
        path: blob.path,
        content: Base64.encode64(blob.local_content.value),
        sha: blob.id,
        message: message,
        committer: committer.git_attrs,
        author: author.git_attrs
      )

      if blob.path && blob.is_a?(Draft)
        blob.stale.value = false
        blob.local_content.value = nil
      end

      blob
    end

    def persisted?
      id.present?
    end
  end
end

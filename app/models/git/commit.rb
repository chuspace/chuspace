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

    def persisted?
      id.present?
    end
  end
end

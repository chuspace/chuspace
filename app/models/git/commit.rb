# frozen_string_literal: true

module Git
  class Commit < ActiveType::Object
    class NotAllowedError < StandardError; end

    attribute :id, :string
    attribute :message, :string
    attribute :patch, :string
    attribute :committed_at, :datetime
    attribute :committer, Git::Committer.new
    attribute :author, Git::Committer.new
    attribute :repository, Repository

    validates :message, :author, :committer, :repository, presence: true

    delegate :git_provider, to: :repository
    delegate :api, to: :git_provider

    class << self
      def from_response(repository, response)
        case response
        when Array
          response.filter_map do |item|
            from_response(repository, item)
          end
        when Sawyer::Resource
          commit = response.commit
          author_hash = commit.author.to_h.merge(username: response.author.login || response.author.username)
          committer_hash = commit.committer.to_h.merge(username: response.author.login || response.author.username)

          Git::Commit.new(
            id: response.id || response.sha,
            message: commit.message,
            author: Git::Committer.from(author_hash),
            committed_at: commit.committer.date,
            patch: response.files&.first&.patch,
            committer: Git::Committer.from(committer_hash),
            repository: repository
          )
        else
          response
        end
      end
    end

    def all(options = { path: nil, ref = repository.default_ref })
      Git::Commit.from_response(api.get("#{repository.endpoint}/commits", **options))
    end

    def find(sha)
      Git::Commit.from_response(api.get("#{repository.endpoint}/commits/#{sha}"))
    end
  end
end

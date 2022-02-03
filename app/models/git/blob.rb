# frozen_string_literal: true

module Git
  class Blob < ActiveType::Object
    attribute :id, :string
    attribute :path, :string
    attribute :name, :string
    attribute :type, :string, default: proc { :blob }
    attribute :content, :string, default: proc { '' }
    attribute :adapter, ApplicationAdapter

    validates :path, :name, :content, :adapter, presence: true

    def create_or_update!(commit:)
      fail NotAllowedError, 'Can not recommit' if commit.persisted?

      publication.git_repository.git_adapter.create_or_update_blob(
        path: path,
        content: Base64.encode64(content),
        sha: id,
        message: commit.message,
        committer: commit.committer.git_attrs,
        author: commit.author.git_attrs
      )
    end

    def to_draft(publication:)
      puts name.inspect

      if MarkdownConfig.valid?(name: name)
        Draft.new(publication: publication, **attributes)
      else
        self
      end
    end

    def commits
      @commits ||= adapter.commits(path: path)
    end

    def persisted?
      id.present?
    end
  end
end

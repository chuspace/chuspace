# frozen_string_literal: true

module Git
  class Blob < ActiveType::Object
    attribute :id, :string
    attribute :path, :string
    attribute :name, :string
    attribute :type, :string, default: proc { :blob }
    attribute :content, :string, default: proc { '' }
    attribute :adapter, ApplicationAdapter

    validates :path, :name, :adapter, presence: true

    def commits
      @commits ||= adapter.commits(path: path)
    end

    def commit(content:, message: nil, committer:, author:)
      fail ArgumentError, 'Not a valid author' unless committer.is_a?(Git::Committer) || author.is_a?(Git::Committer)
      fail TypeError, 'Can not be committed' unless is_a?(Draft) || is_a?(Asset)

      if valid?
        adapter.create_or_update_blob(
          path: path,
          content: Base64.encode64(content),
          sha: id,
          message: message,
          committer: committer,
          author: author
        )
      end

      self
    end

    alias update commit
    alias create commit

    def decorate(publication:)
      if MarkdownValidator.valid?(name_or_path: name)
        Draft.new(publication: publication, **attributes)
      elsif ImageValidator.valid?(name_or_path: name)
        Asset.new(publication: publication, **attributes)
      else
        self
      end
    end

    def delete(message: nil, committer:, author:)
      fail ArgumentError, 'Not a valid author' unless committer.is_a?(Git::Committer) || author.is_a?(Git::Committer)
      fail TypeError, 'Can not be deleted' unless is_a?(Draft) || is_a?(Asset)

      adapter.delete_blob(
        path: path,
        id: sha,
        message: message,
        committer: committer,
        author: author
      )
    end

    def persisted?
      id.present?
    end

    def sha
      id
    end

    def to_param
      name
    end

    def self.valid?(name:)
      MarkdownValidator.valid?(name_or_path: name) || ImageValidator.valid?(name_or_path: name)
    end
  end
end
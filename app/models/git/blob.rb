# frozen_string_literal: true

module Git
  class Blob < ActiveType::Object
    attribute :id, :string
    attribute :path, :string
    attribute :name, :string
    attribute :type, :string, default: proc { :blob }
    attribute :content, :string, default: proc { '' }
    attribute :repository, Repository

    validates :repository, presence: true

    delegate :git_provider, to: :repository
    delegate :api, to: :git_provider, prefix: true

    class << self
      def to_blob(repository, response)
        case response
        when Array
          response.filter_map do |item|
            next unless valid?(name: item.name)

            to_blob(repository, item)
          end
        when Sawyer::Resource
          Git::Blob.new(
            id: response.sha || response.id,
            name: response.name,
            path: response.path,
            type: response.type,
            content: response.content,
            repository: repository
          ).decorate
        else
          response
        end
      end
    end

    def all(paths = repository.contents_folders, options = { ref: repository.default_ref })
      blobs = []

      paths.each do |path|
        endpoint = "#{repository.endpoint}/contents/#{path}"
        blobs += find(path)
      end

      blobs.sort_by { |blob| %w[dir file].index(blob.type) }
    end

    def commit(method:, message:, committer:, author:)
      fail ArgumentError, 'Not a valid author' unless committer.is_a?(Git::Committer) || author.is_a?(Git::Committer)
      fail TypeError, 'Can not be committed' unless is_a?(Draft) || is_a?(Asset)

      if valid?
        endpoint = "#{repository.endpoint}/contents/#{path}"
        git_provider_api.send(method, endpoint, { content: content, message: message, sha: sha, committer: committer, author: author })
      else
        save!
      end

      self
    end

    def commits
      Git::Commit.new(repository: repository, blob: self).all
    end

    def create(message: nil, committer:, author:)
      message ||= "Add #{path}"
      commit(action: :create, message: message, committer: committer, author: author)
    end

    def decorate
      if MarkdownValidator.valid?(name_or_path: name)
        Draft.new(publication: repository.publication, **attributes)
      elsif ImageValidator.valid?(name_or_path: name)
        Asset.new(publication: repository.publication, **attributes)
      else
        self
      end
    end

    def delete(message: nil, committer:, author:)
      message ||= "Delete #{path}"
      commit(action: :update, message: message, committer: committer, author: author)
    end

    def find(path, options = { ref: repository.default_ref })
      Git::Blob.to_blob(repository, git_provider_api.get(normalize_endpoint_path(:find, path: path), options))
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

    def update(message: nil, committer:, author:)
      fail ArgumentError, 'ID can not be blank' unless persisted?
      message ||= "Update #{path}"
      commit(action: :update, message: message, committer: committer, author: author)
    end

    def self.valid?(name:)
      MarkdownValidator.valid?(name_or_path: name) || ImageValidator.valid?(name_or_path: name)
    end
  end
end

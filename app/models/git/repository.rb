# frozen_string_literal: true

module Git
  class Repository < ActiveType::Object
    attribute :id, :string
    attribute :fullname, :string
    attribute :name, :string
    attribute :owner, :string
    attribute :description, :string
    attribute :visibility, :string
    attribute :ssh_url, :string
    attribute :html_url, :string
    attribute :default_branch, :string
    attribute :adapter, ApplicationAdapter
    attribute :publication, Publication

    delegate :repository_files, :repository_folders, :webhooks, to: :adapter

    CONFIG_FILE_PATH = 'chuspace.yml'
    CONNECT_MESSAGE = 'Connect chuspace'
    DISCONNECT_MESSAGE = 'Disconnect chuspace'

    def self.chuspace_yaml_config
      PublicationConfig.new.to_h.deep_stringify_keys.to_yaml
    end

    def config_exists?
      adapter.blob(path: CONFIG_FILE_PATH).persisted?
    end

    def asset(path:)
      blob(path: path)
    end

    def assets(path:)
      blobs(paths: path)
    end

    def draft(path:)
      blob(path: path)
    end

    def drafts(path:)
      blobs(paths: path)
    end

    def markdown_files
      repository_files.select { |path| MarkdownValidator.valid?(name_or_path: path) }
    end

    def readme
      blob(path: publication.repo.readme_path)
    end

    def tree(path:)
      adapter.tree(path: path)
    end

    def with_publication(publication)
      self.publication = publication
      self
    end

    private

    def blobs(paths:)
      Rails.cache.fetch([publication, paths.join(':')]) do
        adapter.blobs(paths: paths)
          .select { |blob| Git::Blob.valid?(name: blob.name) }
          .map { |blob| blob.decorate(publication: publication) }
      end
    end

    def blob(path:)
      fail ActiveRecord::RecordNotFound, 'not found' unless Git::Blob.valid?(name: path)

      Rails.cache.fetch([publication, path]) do
        adapter.blob(path: path).decorate(publication: publication)
      end
    end
  end
end

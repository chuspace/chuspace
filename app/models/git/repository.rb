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

    %w[assets drafts].each do |name|
      define_method "#{name}" do |paths|
        adapter.blobs(paths: paths)
               .select { |blob| Git::Blob.valid?(name: blob.name) }
               .map { |blob| blob.decorate(publication: publication) }
      end
    end

    %w[asset draft].each do |name|
      define_method "#{name}" do |path|
        fail ActiveRecord::RecordNotFound, 'not found' unless Git::Blob.valid?(name: path)

        adapter.blob(path: path).decorate(publication: publication)
      end
    end

    def markdown_files
      repository_files.select { |path| MarkdownValidator.valid?(name_or_path: path) }
    end

    def with_publication(publication)
      self.publication = publication
      self
    end
  end
end

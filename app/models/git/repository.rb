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

    def with_publication(publication)
      self.publication = publication
      self
    end

    %w[assets drafts].each do |name|
      define_method "#{name}" do |paths|
        adapter.blobs(paths: paths).map { |blob| blob.to_draft(publication: publication) }
      end
    end

    %w[asset draft].each do |name|
      define_method "#{name}" do |path|
        adapter.blob(path: path).to_draft(publication: publication)
      end
    end
  end
end

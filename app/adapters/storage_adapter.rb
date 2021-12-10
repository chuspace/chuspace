# frozen_string_literal: true

class StorageAdapter
  class MethodNotImplementedError < StandardError; end
  class StorageAdapterNotFoundError < StandardError; end

  ADAPTERS = {
    chuspace: ChuspaceAdapter,
    github: GithubAdapter,
    github_enterprise: GithubEnterpriseAdapter,
    gitlab: GitlabAdapter,
    gitlab_foss: GitlabFossAdapter,
    gitea: GiteaAdapter
  }.freeze

  REQUIRED_METHODS = %i[
    name
    user
    repository
    repositories
    create_user
    contents
    content
    search_repositories
    create_repository
    delete_repository
    update_repository
    repository_files
    repository_folders
    head_sha
    commits
    blob
    blobs
    create_blob
    update_blob
    delete_blob
    commit
    contribute
    merge
    rebase
    contributors
    tree
  ].freeze

  attr_reader :storage, :adapter

  def initialize(storage:)
    @storage = storage
    adapter_klass = ADAPTERS[@storage.provider.to_sym]
    fail StorageAdapterNotFoundError, "#{@storage.provider} adapter not found" if adapter_klass.nil?

    @adapter = adapter_klass.new(endpoint: @storage.endpoint, access_token: @storage.access_token)
  end

  # @!method repositories
  # List repositories for a user on choosen storage
  # @param user
  # @abstract This should be implemented by the adapter.

  # @!method create_repository
  # Creates a repository on choosen storage
  # @param name
  # @param description
  # @param template_name
  # @param is_private
  # @param user
  # @return repository
  # @abstract This should be implemented by the adapter.
  REQUIRED_METHODS.each do |method|
    define_method(method) do |*_args|
      fail MethodNotImplementedError, "#{method} not implemented for #{adapter.name} adapter"
    end
  end

  def name
    fail MethodNotImplementedError, "name not implemented for #{adapter.name} adapter"
  end

  delegate *REQUIRED_METHODS, to: :adapter
end

# frozen_string_literal: true

class GitAdapter
  class MethodNotImplementedError < StandardError; end
  class GitAdapterNotFoundError < StandardError; end

  ADAPTERS = {
    github: GithubAdapter,
    gitlab: GitlabAdapter
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
    create_repository_webhook
    delete_repository
    delete_repository_webhook
    update_repository
    repository_files
    repository_dirs
    head_sha
    commits
    blob
    blobs
    create_or_update_blob
    create_blob
    update_blob
    delete_blob
    commit
    contribute
    merge
    users
    orgs
    rebase
    contributors
    tree
    webhooks
  ].freeze

  attr_reader :git_provider, :adapter

  def initialize(git_provider:)
    @git_provider = git_provider
    adapter_klass = ADAPTERS[@git_provider.name.to_sym]
    fail StorageAdapterNotFoundError, "#{@git_provider.name} adapter not found" if adapter_klass.nil?

    @adapter = adapter_klass.new(endpoint: @git_provider.endpoint, access_token: @git_provider.access_token)
  end

  # @!method repositories
  # List repositories for a user on choosen git_provider
  # @param user
  # @abstract This should be implemented by the adapter.

  # @!method create_repository
  # Creates a repository on choosen git_provider
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

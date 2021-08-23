# frozen_string_literal: true

class StorageAdapter
  include FaradayClient::Connection
  class MethodNotImplementedError < StandardError; end
  class StorageAdapterNotFoundError < StandardError; end

  ADAPTERS = {
    github: GithubAdapter,
    gitlab: GitlabAdapter,
    bitbucket: BitbucketAdapter
  }.freeze

  REQUIRED_METHODS = %i[
    repositories
    create_repository
    delete_repository
    update_repository
    find_blob
    commit
    contribute
    merge
    rebase
    contributors
  ].freeze

  attr_reader :adapter

  def initialize(storage_id:)
    @storage = Storage.find(storage_id)
    adapter_klass = ADAPTERS[@storage.provider.to_sym]
    fail StorageAdapterNotFoundError, "#{@storage.provider} adapter not found" if adapter_klass.nil?

    @adapter = adapter_klass.new(endpoint: @storage.endpoint, access_token: @storage.access_token)
  end

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

  delegate *REQUIRED_METHODS, to: :adapter
end

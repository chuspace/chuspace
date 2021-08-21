class StorageAdapter
  class NotImplementedError < StandardError; end

  REQUIRED_METHODS = %i[
    create
    delete
    update
    blob
    commit
    contribute
    merge
    rebase
    contributors
  ].freeze

  def initialize(adapter:, endpoint:, access_token:)
    @adapter = adapter
    @endpoint = endpoint
    @token = token
  end

  # @!method create
  # Creates a repository on choosen adapter
  # @param name
  # @param description
  # @param template
  # @param is_private
  # @param user
  # @return repository
  # @abstract This should be implemented by the adapter.
  REQUIRED_METHODS.each do |method|
    define_method(method) do |*_args|
      fail NotImplementedError, "#{method} not implemented for #{adapter} adapter"
    end
  end
end

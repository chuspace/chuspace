# frozen_string_literal: true

class GithubAdapter < StorageAdapter
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'github'
  end

  def repositories(options: {})
    paginate 'repositories', options
  end
end

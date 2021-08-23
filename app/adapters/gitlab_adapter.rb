# frozen_string_literal: true

class GitlabAdapter < StorageAdapter
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'gitlab'
  end

  def repositories
  end
end

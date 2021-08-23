# frozen_string_literal: true

class BitbucketAdapter < StorageAdapter
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'bitbucket'
  end
end

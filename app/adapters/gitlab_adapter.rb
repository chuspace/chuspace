# frozen_string_literal: true

class GitlabAdapter
  include FaradayClient::Connection

  attr_reader :endpoint, :access_token
  delegate :username, to: :user

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'gitlab'
  end

  def user(options = {})
    @user ||= get 'user', options
  end

  def repositories(options: {})
    @repositories ||= paginate "users/#{username}/projects", options
  end
end

# frozen_string_literal: true

class GithubAdapter
  include FaradayClient::Connection

  attr_reader :endpoint, :access_token
  delegate :login, to: :user

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'github'
  end

  def user(options = {})
    @user ||= get 'user', options
  end

  def repositories(options: {})
    @repositories ||= paginate 'user/repos', options
  end
end

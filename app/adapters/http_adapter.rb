# frozen_string_literal: true

class HTTPAdapter
  include FaradayClient::Connection
  attr_accessor :endpoint, :access_token, :access_token_param

  def initialize(endpoint:, access_token:, access_token_param: :token)
    @endpoint = endpoint
    @access_token = access_token
    @access_token_param = access_token_param
  end
end

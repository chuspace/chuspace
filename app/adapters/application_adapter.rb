# frozen_string_literal: true

class ApplicationAdapter
  include FaradayClient::Connection
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  private

  def commit_from_response(response)
    case response
    when Array then response.map { |item| commit_from_response(item) }
    when Sawyer::Resource
      Sawyer::Resource.new(
        agent, {
          id: response.id,
          fullname: response.full_name&.squish || response.path_with_namespace&.squish,
          name: response.name,
          owner: response.namespace&.path || response.owner&.login,
          description: response.description,
          visibility: response.visibility || response.private ? :private : :public,
          ssh_url: response.ssh_url_to_repo || response.ssh_url,
          html_url: response.web_url || response.html_url,
          default_branch: response.default_branch
        }
      )
    else
      Sawyer::Resource.new(agent, {})
    end
  end

  def repository_from_response(response)
    case response
    when Array then response.map { |item| repository_from_response(item) }
    when Sawyer::Resource
      Sawyer::Resource.new(
        agent, {
          id: response.id,
          fullname: response.full_name&.squish || response.path_with_namespace&.squish,
          name: response.name,
          owner: response.namespace&.path || response.owner&.login,
          description: response.description,
          visibility: response.visibility || response.private ? :private : :public,
          ssh_url: response.ssh_url_to_repo || response.ssh_url,
          html_url: response.web_url || response.html_url,
          default_branch: response.default_branch
        }
      )
    else
      Sawyer::Resource.new(agent, {})
    end
  end
end

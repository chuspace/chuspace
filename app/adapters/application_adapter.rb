# frozen_string_literal: true

class ApplicationAdapter
  include FaradayClient::Connection
  attr_reader :endpoint, :access_token, :repo_fullname, :ref

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def apply_repository_scope(repo_fullname:, ref: 'HEAD')
    @repo_fullname = repo_fullname
    @ref = ref

    self
  end

  private

  def blob_from_response(response)
    case response
    when Array then response.map { |item| blob_from_response(item) }
    when Sawyer::Resource
      Sawyer::Resource.new(
        agent, {
          id: response.sha || response.id,
          name: response.name,
          path: response.path,
          type: response.type,
          content: response.content || ''
        }
      )
    else
      response
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
          visibility: response.visibility,
          ssh_url: response.ssh_url_to_repo || response.ssh_url,
          html_url: response.web_url || response.html_url,
          default_branch: response.default_branch
        }
      )
    else
      response
    end
  end
end

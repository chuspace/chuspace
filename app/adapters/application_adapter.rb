# frozen_string_literal: true

class ApplicationAdapter
  include FaradayClient::Connection
  attr_reader :endpoint, :access_token

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  private

  def repository_from_response(response)
    case response
    when nil then Repository.new
    when Array then response.map { |item| repository_from_response(item) }
    when Sawyer::Resource
      case name.to_sym
      when :github, :github_enterprise
        GitRepository.new(
          id: response.id,
          fullname: response.full_name.squish,
          name: response.name,
          owner: response.owner.login,
          description: response.description,
          visibility: response.private ? :private : :public,
          ssh_url: response.ssh_url,
          html_url: response.html_url,
          default_branch: response.default_branch
        )
      when :gitlab, :gitlab_foss
        GitRepository.new(
          id: response.id,
          name: response.path.squish,
          owner: response.namespace.path,
          fullname: response.path_with_namespace.squish,
          description: response.description,
          visibility: response.visibility,
          ssh_url: response.ssh_url_to_repo,
          html_url: response.web_url,
          default_branch: response.default_branch
        )
      when :chuspace, :gitea
        GitRepository.new(
          id: response.id,
          fullname: response.full_name.squish,
          name: response.name.squish,
          owner: response.owner.login,
          description: response.description,
          visibility: response.private ? :private : :public,
          ssh_url: response.ssh_url,
          html_url: response.html_url,
          default_branch: response.default_branch
        )
      end
    end
  end
end

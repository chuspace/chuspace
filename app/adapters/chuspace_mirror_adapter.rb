# frozen_string_literal: true

class ChuspaceMirrorAdapter < GiteaAdapter
  def name
    'chuspace_mirror'
  end

  def self.as_superuser
    endpoint = Rails.application.credentials.chuspace.git_mirror[:endpoint]
    access_token = Rails.application.credentials.chuspace.git_mirror[:access_token]

    new(endpoint: endpoint, access_token: access_token, access_token_param: :token)
  end

  def mirror_repository(repository:)
    repository_from_response(
      post(
        'repos/migrate',
        clone_addr: repository.html_url,
        repo_name: repository.friendly_full_name,
        repo_owner: Rails.application.credentials.chuspace.git_mirror[:org_name],
        auth_token: repository.publication.git_provider.access_token,
        private: true,
        mirror: true,
        git_content: true
      )
    )
  rescue FaradayClient::Conflict
    false
  end

  def delete_repository(repository:)
    boolean_from_response(:delete, "repos/#{repository.mirror_full_name}")
  end
end

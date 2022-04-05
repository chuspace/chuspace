module Mirrorable
  extend ActiveSupport::Concern

  included do
    before_create :create_mirror
    after_destroy :delete_mirror
  end

  def create_mirror
    mirror_repo = Git::Repository.from_response(
      mirror_api.post(
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

    update(mirror_url: mirror_repo.html_url)
  rescue FaradayClient::Conflict
    Git::Repository.from_response(mirror_api.get("repos/#{repository.mirror_full_name}"))
  end

  def delete_mirror(repository:)
    mirror_api.boolean_from_response(:delete, "repos/#{repository.mirror_full_name}")
  end
end

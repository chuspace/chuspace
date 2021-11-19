# frozen_string_literal: true

class ChuspaceAdapter < GiteaAdapter
  attr_accessor :basic_auth, :sudo

  def name
    'chuspace'
  end

  def self.as_superuser
    endpoint = GitStorageConfig.new.chuspace[:endpoint]
    access_token = Rails.application.credentials.storage[:chuspace][:access_token]

    new(endpoint: endpoint, access_token: access_token)
  end

  def create_repository(path:, name:, owner:)
    repository_from_response(
      post(
        "repos/#{path}/generate",
        name: name,
        owner: owner,
        private: true,
        git_content: true
      )
    )
  end

  def create_personal_access_token(username:)
    provider_user_token = post("users/#{username}/tokens", { name: username })
    provider_user_token.sha1
  end

  def create_user(username:, name:, email:)
    user = post(
      'admin/users',
      {
        email: email,
        full_name: name,
        username: username,
        password: SecureRandom.hex(12),
        must_change_password: false,
        send_notify: false,
        visibility: :private
      }
    )

    patch("admin/users/#{username}", {
        max_repo_creation: 5,
        allow_git_hook: false,
        admin: false,
        allow_create_organization: false,
        active: true,
        login_name: username,
        source_id: 0
      }
    )

    user
  end

  def delete_repository(fullname:)
    boolean_from_response(:delete, "repos/#{fullname}")
  end

  def delete_user(username:)
    boolean_from_response(:delete, "admin/users/#{username}")
  end
end

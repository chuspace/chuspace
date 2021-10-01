# frozen_string_literal: true

class ChuspaceAdapter < GiteaAdapter
  attr_accessor :basic_auth, :sudo

  def name
    'chuspace'
  end

  def self.as_superuser
    endpoint = Rails.application.credentials.storage[:chuspace][:endpoint]
    access_token = Rails.application.credentials.storage[:chuspace][:access_token]

    new(endpoint: endpoint, access_token: access_token)
  end

  def user
    @user ||= get('user')
  end

  def create_user(user:)
    user = post(
      'admin/users',
      {
        email: user.email,
        full_name: user.name,
        username: user.username,
        password: SecureRandom.hex(12),
        must_change_password: false,
        send_notify: false,
        visibility: :private
      }
    )

    patch("admin/users/#{user.username}", {
        max_repo_creation: 5,
        allow_git_hook: false,
        admin: false,
        allow_create_organization: false,
        active: true,
        login_name: user.username,
        source_id: 0
      }
    )

    user
  end

  def delete_user(user:)
    boolean_from_response(:delete, "admin/users/#{user.username}")
  end

  def create_personal_access_token(user:)
    provider_user_token = post("users/#{user.username}/tokens", { name: user.username })
    provider_user_token.sha1
  end

  def create_repository(blog:)
    repository_from_response(
      post(
        "repos/#{blog.template_name}/generate",
        name: blog.name,
        owner: blog.user.username,
        private: true,
        git_content: true
      )
    )
  end

  def delete_repository(fullname:)
    boolean_from_response(:delete, "repos/#{fullname}")
  end
end

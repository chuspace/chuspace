# frozen_string_literal: true

class ChuspaceAdapter < GitlabAdapter
  def name
    'chuspace'
  end

  def create_personal_access_token(user_id:)
    post("users/#{user_id}/personal_access_tokens", name: name, scopes: scopes)
  end

  def user(id:)
    @user ||= get("users/#{id}")
  end

  def create_user(user:)
    post(
      'users',
      {
        email: user.email,
        name: user.name,
        username: user.username,
        projects_limit: 100,
        can_create_group: false,
        private_profile: true,
        skip_confirmation: true,
        force_random_password: true
      }
    )
  end

  def create_user_with_token(user:)
    provider_user = create_user(user: user)
    provider_user_token = create_personal_access_token(user_id: provider_user.id)

    [provider_user.id, provider_user_token.token]
  end

  def deactivate_user(user_id:)
    post("users/#{user_id}/deactivate")
  end
end

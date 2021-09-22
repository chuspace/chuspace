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

  def create_repository(blog:)
    project = decorate_repository(
      post(
        'projects',
        name: blog.name,
        path: "#{blog.slug}.chuspace.dev",
        description: blog.description,
        visibility: blog.visibility,
        shared_runners_enabled: true,
        pages_access_level: 'public',
        template_name: :hugo,
        auto_devops_enabled: true
      )
    )

    post("projects/#{project.id}/triggers", description: 'Deploy pages')
    project
  end

  def delete_repository(id:)
    boolean_from_response :delete, "projects/#{id}"
  end

  def deactivate_user(user_id:)
    post("users/#{user_id}/deactivate")
  end
end

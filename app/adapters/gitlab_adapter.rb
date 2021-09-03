# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
  end

  def user
    @user ||= get('user')
  end

  def repository(id:)
    @repository ||= get("projects/#{id}")
  end

  def repositories(storage:)
    @repositories ||= paginate("users/#{storage.provider_user_id}/projects")
  end

  def create_repository(blog:)
    project = post(
      'projects',
      name: blog.name,
      path: "#{blog.slug}.chuspace.dev",
      description: blog.description,
      visibility: blog.visibility,
      shared_runners_enabled: true,
      pages_access_level: 'public',
      template_name: blog.framework
    )

    post("projects/#{project.id}/triggers", description: 'Deploy pages')
  end

  def repository_folders(id:)
    tree = get("projects/#{id}/repository/tree", { recursive: true })
    @repository_folders ||= tree.map(&:path)
  end
end

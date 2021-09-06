# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
  end

  def user
    @user ||= get('user')
  end

  def repository(id:)
    @repository ||= decorate_repository(get("projects/#{id}"))
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    @search_repositories ||= decorate_repository(paginate('search', options.merge(search: query, scope: :projects)))
  end

  def repositories
    @repositories ||= decorate_repository(paginate('projects', { owned: true }))
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
        template_name: blog.framework
      )
    )

    post("projects/#{project.id}/triggers", description: 'Deploy pages')
    project
  end

  def delete_repository(id:)
    boolean_from_response :delete, "projects/#{id}"
  end

  def repository_folders(id:)
    tree = get("projects/#{id}/repository/tree", { recursive: true })
    @repository_folders ||= tree.map(&:path)
  end
end

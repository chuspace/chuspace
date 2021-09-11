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

  def blobs(repo_id:, path:)
    blobs = get "projects/#{repo_id}/repository/tree", { path: path }

    blobs.map do |blob|
      content = find_blob(repo_id: repo_id, id: blob.id)
      Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.id, path: blob.path))
    end
  end

  def find_blob(repo_id:, id:)
    blob = get "projects/#{repo_id}/repository/blobs/#{id}", { ref: :master }
    Sawyer::Resource.new(agent, blob.to_h.merge!(id: id))
  end

  def create_blob(repo_id:, path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    post "projects/#{repo_id}/repository/files/#{CGI.escape(path)}", { branch: :master, encoding: :base64, content: content, commit_message: message }
  end
end

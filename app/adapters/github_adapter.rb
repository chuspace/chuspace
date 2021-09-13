# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def user(options = {})
    @user ||= get('user', options)
  end

  def repositories(options: {})
    @repositories ||= decorate_repository(paginate('user/repos', options))
  end

  def repository(id:)
    @repository ||= decorate_repository(get("repositories/#{id}"))
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    @search_repositories ||= decorate_repository(search('search/repositories', query, options).items)
  end

  def create_repository(blog:)
    puts blog.framework_config.inspect
    decorate_repository(
      post(
        "repos/#{blog.template_name}/generate",
        name: blog.name,
        description: blog.description,
        private: blog.visibility.private?,
        accept: 'application/vnd.github.baptiste-preview+json'
      )
    )
  end

  def delete_repository(id:)
    boolean_from_response :delete, "repositories/#{id}"
  end

  def repository_folders(id:)
    repo_sha = paginate("repositories/#{id}/commits", { per_page: 1 }).first.sha
    tree = get("repositories/#{id}/git/trees/#{repo_sha}", { recursive: true }).tree
    @repo_folders = tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def blobs(repo_id:, path:)
    blobs = get "repositories/#{repo_id}/contents/#{path}"

    blobs.map do |blob|
      content = find_blob(repo_id: repo_id, id: blob.sha)
      Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.sha, path: blob.path))
    end
  end

  def find_blob(repo_id:, id:)
    get "repositories/#{repo_id}/git/blobs/#{id}", {}
  end

  def create_blob(repo_id:, path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    put "repositories/#{repo_id}/contents/#{path}", { content: content, message: message }
  end

  def delete_blob(repo_id:, path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "repositories/#{repo_id}/contents/#{path}", { sha: id, message: message }
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

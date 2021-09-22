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
    post "projects/#{repo_id}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message }
  end

  def delete_blob(repo_id:, path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "projects/#{repo_id}/repository/files/#{CGI.escape(path)}", { branch: :master, commit_message: message }
  end
end

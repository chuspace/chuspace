# frozen_string_literal: true

class GiteaAdapter < ApplicationAdapter
  def name
    'gitea'
  end

  def user
    @user ||= get('user')
  end

  def repository(repo:)
    @repository ||= repository_from_response(get("repos/#{repo.owner}/#{repo.name}"))
  end

  def repository_folders(repo:)
    tree = get("repos/#{repo.owner}/#{repo.name}/contents")
    @repository_folders ||= tree.map(&:path)
  end

  def blobs(blog:)
    username = blog.user.username
    repo_id = blog.git_repo_id

    blobs = get "repos/#{username}/#{repo_id}/contents/#{blog.posts_folder}"

    blobs.map do |blob|
      content = find_blob(repo_id: repo_id, id: blob.path)
      Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.id, path: blob.path))
    end
  end

  def find_blob(repo_id:, id:)
    blob = get "repos/#{username}/#{repo_id}/contents/#{id}"
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

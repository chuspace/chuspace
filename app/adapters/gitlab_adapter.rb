# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
  end

  def user
    @user ||= get('user')
  end

  def repository(fullname:)
    @repository ||= repository_from_response(get("projects/#{CGI.escape(fullname)}"))
  end

  def head_sha(fullname:)
    @head_sha ||= paginate("projects/#{CGI.escape(fullname)}/repository/commits", { per_page: 1 }).first.id
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    @search_repositories ||= repository_from_response(paginate('search', options.merge(search: query, scope: :projects)))
  end

  def repository_folders(fullname:)
    tree = get("projects/#{CGI.escape(fullname)}/repository/tree", { recursive: true })
    @repository_folders ||= tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def blobs(fullname:, path:)
    blobs = get "projects/#{CGI.escape(fullname)}/repository/tree", { path: path }

    blobs.map do |blob|
      next if blob.type == 'tree'

      content = find_blob(fullname: fullname, id: blob.id)
      Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.id, path: blob.path))
    end.compact
  end

  def find_blob(fullname:, id:)
    blob = get "projects/#{CGI.escape(fullname)}/repository/blobs/#{id}"
    Sawyer::Resource.new(agent, blob.to_h.merge!(id: id))
  end

  def create_blob(fullname:, path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    post "projects/#{CGI.escape(fullname)}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message }
  end

  def update_blob(fullname:, path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    put "projects/#{CGI.escape(fullname)}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message }
  end

  def delete_blob(fullname:, path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "projects/#{CGI.escape(fullname)}/repository/files/#{CGI.escape(path)}", { branch: :master, commit_message: message }
  end
end

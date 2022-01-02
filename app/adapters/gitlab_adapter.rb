# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
  end

  def user
    get('user')
  end

  def repository(fullname:)
    repository_from_response(get("projects/#{CGI.escape(fullname)}"))
  end

  def head_sha(fullname:)
    paginate("projects/#{CGI.escape(fullname)}/repository/commits", { per_page: 1 }).first.id
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    repository_from_response(paginate('search', options.merge(search: query, scope: :projects)))
  end

  def repository_dirs(fullname:)
    tree = get("projects/#{CGI.escape(fullname)}/repository/tree", { recursive: true })
    tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def blobs(fullname:, paths: [])
    items = []

    paths.each do |path|
      response = get "projects/#{CGI.escape(fullname)}/repository/tree", { path: path }
      case response
      when Array
        items += response.select { |item| item.type == 'file' && Post.valid_mime?(name: item.path) }
        dirs = response.select { |item| item.type == 'dir' }
        next unless dirs.any?

        items += blobs(fullname: fullname, paths: dirs.map(&:path))
      when Sawyer::Resource
        content = blob(fullname: fullname, id: blob.id)
        items << Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.id, path: blob.path))
      end
    rescue FaradayClient::NotFound
      next
    end

    items
  end

  def blob(fullname:, id:)
    blob = get "projects/#{CGI.escape(fullname)}/repository/blobs/#{id}"
    Sawyer::Resource.new(agent, blob.to_h.merge!(id: id))
  rescue FaradayClient::NotFound
    Sawyer::Resource.new(agent, {})
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

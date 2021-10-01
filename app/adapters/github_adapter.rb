# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def user(options = {})
    @user ||= get('user', options)
  end

  def repository(fullname:)
    @repository ||= repository_from_response(get("repos/#{fullname}"))
  end

  def head_sha(fullname:)
    @head_sha ||= paginate("repos/#{fullname}/commits", { per_page: 1 }).first.sha
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    @search_repositories ||= repository_from_response(search('search/repositories', query, options).items)
  end

  def repository_folders(fullname:)
    tree = get("repos/#{fullname}/git/trees/#{head_sha(fullname: fullname)}", { recursive: true }).tree
    @repo_folders = tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def blobs(fullname:, path:)
    blobs = get "repos/#{fullname}/contents/#{path}"

    blobs.map do |blob|
      next if blob.type == 'tree'

      find_blob(fullname: fullname, id: blob.sha)
    end
  end

  def find_blob(fullname:, id:)
    content = get "repos/#{fullname}/git/blobs/#{id}", {}
    Sawyer::Resource.new(agent, content.to_h.merge!(id: id))
  end

  def create_blob(fullname:, path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    put "repos/#{fullname}/contents/#{path}", { content: content, message: message }
  end

  def delete_blob(fullname:, path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "repos/#{fullname}/contents/#{path}", { sha: id, message: message }
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

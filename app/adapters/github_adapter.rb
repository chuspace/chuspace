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

  def blobs(fullname:, paths:)
    items = []

    paths.each do |path|
      response = get("repos/#{fullname}/contents/#{path}")
      case response
      when Array
        items += response.select { |item| item.type == 'file' }
        dirs = response.select { |item| item.type == 'dir' }
        items += blobs(fullname: fullname, paths: dirs.map(&:path))
      when Sawyer::Resource then items << response
      end
    rescue FaradayClient::NotFound
      next
    end

    items
  end

  def blob(fullname:, path:)
    get "repos/#{fullname}/contents/#{path}"
  rescue FaradayClient::NotFound
    Sawyer::Resource.new(agent, {})
  end

  def create_blob(fullname:, path:, content:, message: nil)
    message ||= "Adding #{path}"
    post "repos/#{fullname}/contents/#{path}", { content: content, message: message }
  end

  def update_blob(fullname:, path:, content:, message: nil)
    message ||= "Adding #{path}"
    put "repos/#{fullname}/contents/#{path}", { content: content, message: message }
  end

  def delete_blob(fullname:, path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "repos/#{fullname}/contents/#{path}", { sha: id, message: message }
  end

  def commits(fullname:, path: nil)
    commits = get("repos/#{fullname}/commits", { path: path })

    commits.map do |commit|
      commit_data = commit(fullname: fullname, sha: commit.sha)
      Sawyer::Resource.new(agent, commit_data.to_h)
    end
  end

  def commit(fullname:, sha:)
    get("repos/#{fullname}/commits/#{sha}")
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

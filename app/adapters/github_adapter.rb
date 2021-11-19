# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def blobs(fullname:, folders: [])
    items = []

    folders.each do |folder|
      response = get("repos/#{fullname}/contents/#{folder}")
      response.each do |item|
        mime = Marcel::MimeType.for name: item.name
        next unless item.type == 'file' && Blob::MIMES.include?(mime)

        items << blob(fullname: fullname, path: item.path)
      end

      dirs = response.select { |item| item.type == 'dir' }
      next unless dirs.any?

      items += blobs(fullname: fullname, folders: dirs.map(&:path))
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

  def commits(fullname:, path: nil)
    opts = {}
    opts[:path] = path if path

    commits = get("repos/#{fullname}/commits", **opts)

    commits.map do |commit|
      commit_data = commit(fullname: fullname, sha: commit.sha)
      Sawyer::Resource.new(agent, commit_data.to_h)
    end
  end

  def commit(fullname:, sha:)
    get("repos/#{fullname}/commits/#{sha}")
  end

  def create_blob(fullname:, path:, content:, message: nil)
    message ||= "Create #{path}"
    post "repos/#{fullname}/contents/#{path}", { content: content, message: message }
  end

  def delete_blob(fullname:, path:, id:, message: nil)
    message ||= "Delete #{path}"
    delete "repos/#{fullname}/contents/#{path}", { sha: id, message: message }
  end

  def head_sha(fullname:)
    @head_sha ||= paginate("repos/#{fullname}/commits", { per_page: 1 }).first.sha
  end

  def repository(fullname:)
    repository_from_response(get("repos/#{fullname}"))
  end

  def repository_folders(fullname:)
    tree(fullname: fullname)
      .select { |item| item.type == 'tree' }
      .map(&:path)
      .sort
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    repository_from_response(search('search/repositories', query, options).items)
  end

  def tree(fullname:, sha: head_sha(fullname: fullname))
    get("repos/#{fullname}/git/trees/#{sha}", { recursive: true }).tree
  end

  def update_blob(fullname:, path:, content:, message: nil)
    message ||= "Update #{path}"
    put "repos/#{fullname}/contents/#{path}", { content: content, message: message }
  end

  def user(options = {})
    get('user', options)
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

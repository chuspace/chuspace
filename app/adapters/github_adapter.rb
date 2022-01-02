# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def blobs(fullname:, dirs: [])
    items = []

    dirs.each do |dir|
      response = get("repos/#{fullname}/contents/#{CGI.escape(dir)}")
      items += response.select { |item| item.type == 'file' && Post.valid_mime?(name: item.path) }

      dirs = response.select { |item| item.type == 'dir' }
      next if dirs.blank?

      items += blobs(fullname: fullname, dirs: dirs.map(&:path))
    rescue FaradayClient::NotFound
      next
    end

    items
  end

  def blob(fullname:, path:, ref: nil)
    opts = {}
    opts[:ref] = ref if ref

    get "repos/#{fullname}/contents/#{CGI.escape(path)}", opts
  rescue FaradayClient::NotFound
    Sawyer::Resource.new(agent, {})
  end

  def commits(fullname:, path: nil)
    opts = {}
    opts[:path] = path if path

    get("repos/#{fullname}/commits", **opts)
  end

  def commit(fullname:, sha:)
    get("repos/#{fullname}/commits/#{sha}")
  end

  def create_repository_webhook(fullname:, type: nil)
    url = if Rails.env.production?
      Rails.application.routes.url_helpers.webhooks_github_repos_url
    else
      Rails.application.routes.url_helpers.webhooks_github_repos_url(host: Rails.application.credentials.webhooks[:dev_host])
    end

    payload = {
      events: %w[push repository],
      active: true,
      config: {
        url: url,
        content_type: 'json',
        secret: Rails.application.credentials.webhooks[:secret]
      }
    }

    payload[:type] = type if type
    post("repos/#{fullname}/hooks", payload)
  end

  def delete_repository_webhook(fullname:, id:)
    boolean_from_response(:delete, "repos/#{fullname}/hooks/#{id}")
  end

  def delete_blob(fullname:, path:, id:, message: nil)
    message ||= "Delete #{path}"
    delete "repos/#{fullname}/contents/#{path}", { sha: id, message: message }
  end

  def head_sha(fullname:)
    @head_sha ||= paginate("repos/#{fullname}/commits", { per_page: 1 }).first.sha
  rescue FaradayClient::NotFound
    nil
  end

  def users
    [user] + orgs
  end

  def orgs(options: {})
    get('user/orgs', options)
  end

  def repositories(username:)
    repository_from_response(get("users/#{username}/repos", { affiliation: 'owner,organization_member' }))
  end

  def repository(fullname:)
    repository_from_response(get("repos/#{fullname}"))
  rescue FaradayClient::NotFound
    nil
  end

  def repository_dirs(fullname:)
    tree(fullname: fullname)
      .select { |item| item.type == 'tree' }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def repository_files(fullname:)
    tree(fullname: fullname)
      .select { |item| item.type == 'blob' && Post.valid_mime?(name: item.path) }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def search_repositories(query:, options: { sort: 'asc', per_page: 5 })
    repository_from_response(search('search/repositories', query, options).items)
  end

  def tree(fullname:, sha: head_sha(fullname: fullname))
    get("repos/#{fullname}/git/trees/#{sha}", { recursive: true }).tree
  end

  def create_or_update_blob(fullname:, path:, content:, committer:, author:, sha: nil, message: nil)
    message ||= sha.blank? ? "Create #{path}" : "Update #{path}"
    put "repos/#{fullname}/contents/#{path}", { content: content, message: message, sha: sha, committer: committer, author: author }
  end

  def user(options: {})
    get('user', options)
  end

  def webhooks(fullname:, options: { per_page: 30 })
    get("repos/#{fullname}/hooks", options)
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

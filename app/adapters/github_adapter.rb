# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def blobs(paths: [])
    opts = { ref: ref }
    blobs = []

    paths.each do |path|
      blobs += blob_from_response(blob(path: path)).sort_by { |blob| %w[dir file].index(blob.type) }
    end

    blobs
  end

  def blob(path:)
    opts = { ref: ref }
    blob_from_response(get("repos/#{repo_fullname}/contents/#{CGI.escape(path)}", **opts))
  rescue FaradayClient::NotFound
    Git::Blob.new
  end

  def commits(path: nil)
    opts = { ref: ref }
    opts[:path] = path if path

    commit_from_response(get("repos/#{repo_fullname}/commits", **opts))
  end

  def commit(sha:)
    commit_from_response(get("repos/#{repo_fullname}/commits/#{sha}"))
  end

  def create_blob(path:, content:, committer:, author:, sha: nil, message: nil)
    message ||= "Create #{path}"
    update_blob(path: path, content: content, committer: committer, author: author, sha: sha, message: message)
  end

  def create_repository_webhook(type: nil)
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
    post("repos/#{repo_fullname}/hooks", payload)
  end

  def delete_repository_webhook(id:)
    boolean_from_response(:delete, "repos/#{repo_fullname}/hooks/#{id}")
  end

  def delete_blob(path:, id:, message: nil, committer:, author:)
    message ||= "Delete #{path}"
    blob_from_response(delete("repos/#{repo_fullname}/contents/#{path}", { sha: id, message: message }).content)
  end

  def head_sha
    @head_sha ||= paginate("repos/#{repo_fullname}/commits", { per_page: 1 }).first.sha
  rescue FaradayClient::NotFound
    nil
  end

  def orgs(options: {})
    user_from_response(get('user/orgs', options))
  end

  def repositories(username:)
    repository_from_response(get("users/#{username}/repos", { affiliation: 'owner,organization_member' }))
  end

  def repository
    repository_from_response(get("repos/#{repo_fullname}"))
  rescue FaradayClient::NotFound
    nil
  end

  def repository_folders
    tree
      .select { |item| item.type == 'tree' }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def repository_files
    tree
      .select { |item| item.type == 'blob' }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def search_repositories(query:, login:, options: { sort: 'asc', per_page: 5 })
    query = "#{query} user:#{login}"
    repository_from_response(search('search/repositories', query, options).items)
  end

  def tree(sha: head_sha)
    get("repos/#{repo_fullname}/git/trees/#{sha}", { recursive: true }).tree
  end

  def update_blob(path:, content:, committer:, author:, sha:, message: nil)
    message ||= "Update #{path}"
    blob_from_response(put("repos/#{repo_fullname}/contents/#{path}", { content: content, message: message, sha: sha, committer: committer, author: author }).content)
  end

  def user(options: {})
    user_from_response(get('user', options))
  end

  def users
    [user] + orgs
  end

  def webhooks(options: { per_page: 30 })
    get("repos/#{repo_fullname}/hooks", options)
  end

  private

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

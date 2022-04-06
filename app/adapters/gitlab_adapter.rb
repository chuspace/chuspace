# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
  end

  def blobs(paths: [])
    items = []

    paths.each do |path|
      items += blob_from_response(get("projects/#{CGI.escape(repo_fullname)}/repository/tree", { path: path }))
    rescue FaradayClient::NotFound
      next
    end

    items
  end

  def blob(path:)
    blob_from_response(get("projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { ref: head_sha }))
  rescue FaradayClient::NotFound
    Git::Blob.new(path: path)
  end

  def commits(path: nil)
    opts = { ref_name: ref, all: true }
    opts[:path] = path if path
    commit_from_response(paginate("projects/#{CGI.escape(repo_fullname)}/repository/commits", **opts))
  end

  def commit(sha:)
    commit_from_response(get("projects/#{CGI.escape(repo_fullname)}/repository/commits/#{sha}"))
  end

  def create_blob(path:, content:, message: nil, committer:, author:)
    message ||= "Add #{path}"
    post "projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message, author_email: author.email, author_name: author.name }
  end

  def create_repository_webhook
    url = if Rails.env.production?
      Rails.application.routes.url_helpers.webhooks_github_repos_url
    else
      Rails.application.routes.url_helpers.webhooks_github_repos_url(host: Rails.application.credentials.webhooks[:dev_host])
    end

    payload = {
      url: url,
      token: Rails.application.credentials.webhooks[:secret],
      push_events: true
    }

    post("projects/#{CGI.escape(repo_fullname)}/hooks", payload)
  end

  def delete_blob(path:, id:, message: nil, committer:, author:)
    message ||= "Delete #{path}"
    delete "projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { branch: :master, commit_message: message, author_email: author.email, author_name: author.name }
  end

  def delete_repository_webhook(id:)
    boolean_from_response(:delete, "projects/#{CGI.escape(repo_fullname)}/hooks/#{id}")
  end

  def head_sha
    paginate("projects/#{CGI.escape(repo_fullname)}/repository/commits", { per_page: 1 }).first.id
  end

  def update_blob(path:, content:, sha:, message: nil, committer:, author:)
    message ||= "Update #{path}"
    put "projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message, author_email: author.email, author_name: author.name }
  end

  def orgs(options: {})
    user_from_response(get('groups', { owned: true, all_available: false }))
  end

  def repository_files
    tree
      .select { |item| item.type == 'blob' }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def repository
    repository_from_response(get("projects/#{CGI.escape(repo_fullname)}"))
  end

  def repository_folders
    tree = get("projects/#{CGI.escape(repo_fullname)}/repository/tree", { recursive: true })
    tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def search_repositories(query:, login:, options: { sort: 'asc', per_page: 5 })
    repository_from_response(paginate("groups/#{CGI.escape(login)}/projects", options.merge(search: query, owned: true, membership: true, search_namespaces: false)))
  end

  def tree(sha: head_sha)
    get "projects/#{CGI.escape(repo_fullname)}/repository/tree", { ref: sha, recursive: true }
  end

  def user
    get('user')
  end

  def users
    [user] + orgs
  end

  def webhooks(options: { per_page: 30 })
    get("projects/#{CGI.escape(repo_fullname)}/hooks", options)
  end
end

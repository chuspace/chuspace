# frozen_string_literal: true

class GitlabAdapter < ApplicationAdapter
  def name
    'gitlab'
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

  # webhooks
  # delete_repository_webhook
  # orgs
  # repositories
  # commit
  # repository_files
  # users
  # commits

  def user
    get('user')
  end

  def repository
    repository_from_response(get("projects/#{CGI.escape(repo_fullname)}"))
  end

  def head_sha
    paginate("projects/#{CGI.escape(repo_fullname)}/repository/commits", { per_page: 1 }).first.id
  end

  def search_repositories(query:, login:, options: { sort: 'asc', per_page: 5 })
    repository_from_response(paginate("groups/#{CGI.escape(login)}/projects", options.merge(search: query, owned: true, membership: true, search_namespaces: false)))
  end

  def repository_folders
    tree = get("projects/#{CGI.escape(repo_fullname)}/repository/tree", { recursive: true })
    tree.select { |item| item.type == 'tree' }.map(&:path).sort
  end

  def blobs(paths: [])
    items = []

    paths.each do |path|
      response = get "projects/#{CGI.escape(repo_fullname)}/repository/tree", { path: path }
      case response
      when Array
        items += response.select { |item| item.type == 'file' && MarkdownConfig.valid?(name: item.path) }
        dirs = response.select { |item| item.type == 'dir' }
        next unless dirs.any?

        items += blobs(paths: dirs.map(&:path))
      when Sawyer::Resource
        content = blob(id: blob.id)
        items << Sawyer::Resource.new(agent, content.to_h.merge!(id: blob.id, path: blob.path))
      end
    rescue FaradayClient::NotFound
      next
    end

    items
  end

  def blob(path:)
    blob = get "projects/#{CGI.escape(repo_fullname)}/repository/blobs/#{path}"
    Sawyer::Resource.new(agent, blob.to_h.merge!(id: id))
  rescue FaradayClient::NotFound
    Sawyer::Resource.new(agent, {})
  end

  def update_blob(path:, content:, message: nil)
    content = Base64.strict_encode64(content)
    message ||= "Adding #{path}"
    put "projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { branch: :main, encoding: :base64, content: content, commit_message: message }
  end

  def orgs(options: {})
    user_from_response(get('groups', { owned: true, all_available: false }))
  end

  def users
    [user] + orgs
  end

  def delete_blob(path:, id:, message: nil)
    message ||= "Deleting #{path}"
    delete "projects/#{CGI.escape(repo_fullname)}/repository/files/#{CGI.escape(path)}", { branch: :master, commit_message: message }
  end

  def repository_files
    tree
      .select { |item| item.type == 'blob' }
      .map(&:path)
      .sort
  rescue FaradayClient::NotFound
    nil
  end

  def tree(sha: head_sha)
    get "projects/#{CGI.escape(repo_fullname)}/repository/tree", { ref: sha, recursive: true }
  end
end

# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  attr_accessor :requestor

  def name
    'github'
  end

  def app_installed?(id:)
    execute_as(:app) do
      get "app/installations/#{id}"
    end

  rescue FaradayClient::NotFound
    false
  end

  def asset(sha:)
    opts = { ref: ref }
    get("repos/#{repo_fullname}/git/blobs/#{sha}", **opts)
  rescue FaradayClient::NotFound
    Git::Blob.new
  end

  def blobs(paths: [])
    opts = { ref: ref }
    blobs = []

    paths.each do |path|
      response = blob(path: path)
      blobs += response.is_a?(Array) ? response : [response]
    rescue FaradayClient::NotFound
      next
    end

    blob_from_response(blobs).sort_by { |blob| %w[dir file].index(blob.type) }
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

  def create_blob(path:, content:, author:, sha: nil, message: nil)
    message ||= "Create #{path}"
    update_blob(path: path, content: content, author: author, sha: sha, message: message)
  end

  def delete_blob(path:, id:, message: nil, author:)
    message ||= "Delete #{path}"
    blob_from_response(delete("repos/#{repo_fullname}/contents/#{path}", { sha: id, message: message }).content)
  end

  def head_sha
    @head_sha ||= paginate("repos/#{repo_fullname}/commits", { per_page: 1 }).first.sha
  rescue FaradayClient::NotFound
    nil
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

  def tree(ref: 'HEAD')
    get("repos/#{repo_fullname}/git/trees/#{ref}", { recursive: true }).tree
  end

  def update_blob(path:, content:, author:, sha:, message: nil)
    message ||= "Update #{path}"
    blob_from_response(put("repos/#{repo_fullname}/contents/#{path}", { content: content, message: message, sha: sha, author: author }).content)
  end

  # Github app endpoints
  def refresh_app_installation_token
    ActiveRecord::Base.connected_to(role: :writing) do
      execute_as(:app) do
        response = post "app/installations/#{git_provider.app_installation_id}/access_tokens"
        git_provider.update(machine_access_token: response.token, machine_access_token_expires_at: response.expires_at)
      end
    end
  end

  # User to server endpoints
  def orgs
    execute_as(:user) do
      user_from_response(get('user/orgs'))
    end
  end

  def user
    execute_as(:user) do
      user_from_response(get('user'))
    end
  end

  def users
    execute_as(:user) do
      [user] + orgs
    end
  end

  def topics(query:)
    search('search/topics', query, per_page: 100, accept: 'application/vnd.github.mercy-preview+json')
  end

  def access_token
    case requestor
    when :user then git_provider.user_access_token
    when :app then authentication_payload
    else refresh_or_fetch_new_machine_token
    end
  end

  def access_token_param
    case requestor
    when :app then 'Bearer'
    else git_provider.user_access_token_param
    end
  end

  private

  def authentication_payload
    payload = {
      iat: Time.now.to_i,
      exp: 10.minutes.from_now.to_i,
      iss: Rails.application.credentials.github_storage[:app_id],
    }

    key = OpenSSL::PKey::RSA.new(Rails.application.credentials.github_storage[:private_key])
    JWT.encode(payload, key, 'RS256')
  end

  def refresh_or_fetch_new_machine_token
    if git_provider.machine_access_token.present? && git_provider.machine_access_token_expires_at > Time.current.utc
      git_provider.machine_access_token
    else
      refresh_app_installation_token
    end

    git_provider.machine_access_token
  end

  def execute_as(requestor)
    self.requestor = requestor
    response = yield
    self.requestor = :server
    response
  end

  def search(path, query, options = {})
    opts = options.merge(q: query)

    paginate(path, opts) do |data, last_response|
      data.items.concat last_response.data.items
    end
  end
end

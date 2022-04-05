# frozen_string_literal: true

class ApplicationAdapter
  class MethodNotImplementedError < StandardError; end

  include FaradayClient::Connection
  attr_accessor :endpoint, :access_token, :access_token_param, :repo_fullname, :ref

  REQUIRED_METHODS = %w[
    blob
    blobs
    create_blob
    create_repository_webhook
    commit
    commits
    delete_repository_webhook
    delete_blob
    head_sha
    orgs
    repository
    repositories
    repository_folders
    repository_files
    search_repositories
    tree
    update_blob
    users
    user
    webhooks
  ]

  def initialize(endpoint:, access_token:, access_token_param: :token)
    @endpoint = endpoint
    @access_token = access_token
    @access_token_param = access_token_param

    # check_method_implementation!
  end

  def apply_repository_scope(repo_fullname:, ref: 'HEAD')
    @repo_fullname = repo_fullname
    @ref = ref

    self
  end

  def mirror
    ChuspaceMirrorAdapter.as_superuser
  end

  def name
    fail MethodNotImplementedError, "name not implemented for #{self.class.name} adapter"
  end

  private

  def check_method_implementation!
    errors = []

    REQUIRED_METHODS.each do |method|
      next if respond_to?(method)
      errors << method
    end

    if errors.any?
      errors << ["\n"]
      errors << "not implemented for #{self.class.name} adapter"
      fail MethodNotImplementedError, errors.join("\n")
    end
  end

  def blob_from_response(response)
    case response
    when Array then response.map { |item| blob_from_response(item) }
    when Sawyer::Resource
      Git::Blob.new(
        id: response.sha || response.id,
        name: response.name,
        path: response.path,
        type: response.type,
        content: response.content,
        adapter: self
      )
    else
      response
    end
  end

  def commit_from_response(response)
    case response
    when Array then response.map { |item| commit_from_response(item) }
    when Sawyer::Resource
      commit = response.commit
      author_hash = commit.author.to_h.merge(username: response.author.login || response.author.username)
      committer_hash = commit.committer.to_h.merge(username: response.author.login || response.author.username)

      Git::Commit.new(
        id: response.id || response.sha,
        message: commit.message,
        author: Git::Committer.from(author_hash),
        committed_at: commit.committer.date,
        patch: response.files&.first&.patch,
        committer: Git::Committer.from(committer_hash),
        adapter: self
      )
    else
      response
    end
  end

  def repository_from_response(response)
    case response
    when Array then response.map { |item| repository_from_response(item) }
    when Sawyer::Resource
      Git::Repository.new(
        id: response.id,
        fullname: response.full_name&.squish || response.path_with_namespace&.squish,
        name: response.name,
        owner: response.namespace&.path || response.owner&.login,
        description: response.description,
        visibility: response.visibility || response.owner&.visibility,
        ssh_url: response.ssh_url_to_repo || response.ssh_url,
        html_url: response.web_url || response.html_url,
        default_branch: response.default_branch,
        adapter: self
      )
    else
      response
    end
  end

  def user_from_response(response)
    case response
    when Array then response.map { |item| user_from_response(item) }
    when Sawyer::Resource
      Git::Committer.new(
        id: response.id,
        name: response.name,
        username: response.login || response.username || response.full_path,
        avatar_url: response.avatar_url
      )
    else
      response
    end
  end
end

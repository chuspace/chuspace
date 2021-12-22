# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def create_repository_webhook(fullname:, type: nil)
    super(fullname: fullname, type: :gitea)
  end

  def create_or_update_blob(fullname:, path:, content:, sha:, message: nil, committer:, author:)
    message ||= sha.blank? ? "Create #{path}" : "Update #{path}"
    post "repos/#{fullname}/contents/#{path}", { content: content, message: message, sha: sha, committer: committer, author: author }
  end

  def search_repositories(query:, options: { per_page: 5 })
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end
end

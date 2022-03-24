# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def commits(path: nil)
    opts = {}
    opts[:path] = path if path
    commits = get("repos/#{repo_fullname}/commits", **opts)

    if path
      commits.select { |commit| commit.files.map(&:filename).include?(path) }
    else
      commits
    end
  end

  def create_or_update_blob(path:, content:, committer:, author:, sha: nil, message: nil)
    options = { content: content, committer: committer, author: author }

    if sha.blank?
      blob_from_response(post("repos/#{repo_fullname}/contents/#{path}", { message: "Create #{path}", **options }).content)
    else
      blob_from_response(put("repos/#{repo_fullname}/contents/#{path}", { message: "Update #{path}", **options }).content)
    end
  end

  def create_repository_webhook(type: nil)
    super(type: :gitea)
  end

  def search_repositories(query:, login:, options: { per_page: 5 })
    options[:uid] = users.find { |user| user.username == login }.id
    options[:exclusive] = true
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end
end

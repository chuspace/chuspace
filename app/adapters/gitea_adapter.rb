# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def commits(path: nil)
    commits = super(path: path)

    if path
      commits.select { |commit| commit.files.map(&:filename).include?(path) }
    else
      commits
    end
  end

  def create_blob(path:, content:, committer:, author:, sha: nil, message: nil)
    options = { content: content, committer: committer, author: author }

    blob_from_response(post("repos/#{repo_fullname}/contents/#{path}", { message: "Create #{path}", **options }).content)
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

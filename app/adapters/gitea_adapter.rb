# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def search_repositories(query:, options: { per_page: 5 })
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end

  def commits(fullname:, path:)
    commits = get("repos/#{fullname}/commits", { path: path })
    commits.select { |commit| commit.files.map(&:filename).include?(path) }
  end
end

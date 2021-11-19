# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def commits(fullname:, path: nil)
    opts = {}
    opts[:path] = path if path
    commits = get("repos/#{fullname}/commits", **opts)

    if path
      commits.select { |commit| commit.files.map(&:filename).include?(path) }
    else
      commits
    end
  end

  def search_repositories(query:, options: { per_page: 5 })
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end
end

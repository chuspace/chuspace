# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def search_repositories(query:, options: { per_page: 5 })
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end
end

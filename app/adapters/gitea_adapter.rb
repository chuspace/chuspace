# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
  end

  def create_repository_webhook(fullname:, type: nil)
    super(fullname: fullname, type: :gitea)
  end

  def search_repositories(query:, options: { per_page: 5 })
    @search_repositories ||= repository_from_response(search('repos/search', query, options).data)
  end
end

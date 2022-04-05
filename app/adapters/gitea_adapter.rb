# frozen_string_literal: true

class GiteaAdapter < GithubAdapter
  def name
    'gitea'
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

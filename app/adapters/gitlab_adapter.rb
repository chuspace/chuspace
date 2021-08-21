class GithubAdapter
  attr_reader :client

  def initialize(endpoint, access_token)
    @client = Octokit::Client.new(access_token: access_token, api_endpoint: endpoint)
  end

  def create_repository(params:)
    client.create_repository_from_template(template, name, accept: Octokit::Preview::PREVIEW_TYPES[:template_repositories], private: private_repo, owner: owner, description: description)
  end

  def delete_repository(repo:)
    client.delete_repository(repo)
  end

  def update_repository(repo:, name:, description:)
    client.update_repository(repo, )
  end

  def find_blob(path:)
  end

  def all_prs
  end

  def create_pr(params:)
  end

  def close_pr(id:)
  end

  def merge_pr(id:)
  end

  def update_pr(id:)
  end

  def contributors(repo:)
  end
end

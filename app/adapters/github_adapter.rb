class GithubAdapter
  attr_reader :client

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @token = token
    @client = Octokit::Client.new(access_token: access_token, api_endpoint: endpoint)
  end

  def create()
    client.create_repository_from_template('gauravtiwari/blog-template', params[:blog][:name], accept: Octokit::Preview::PREVIEW_TYPES[:template_repositories], private: params[:blog][:private] == 'true', **create_blog_params)
  end

  def delete
  end

  def update
  end

  def blob
  end

  def commit
  end

  def contribute
  end

  def merge
  end

  def rebase
  end

  def contributors
  end
end

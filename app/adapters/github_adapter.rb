# frozen_string_literal: true

class GithubAdapter < ApplicationAdapter
  def name
    'github'
  end

  def user(options = {})
    @user ||= get('user', options)
  end

  def repositories(options: {})
    @repositories ||= paginate('user/repos', options)
  end

  def repository(id:)
    @repository ||= get("user/repos/#{id}")
  end

  def create_repository(blog:)
    post(
      "repos/#{blog.framework_template}/generate",
      name: blog.name,
      description: blog.description,
      private: blog.visibility.private?,
      user: blog.provider_user.username
    )
  end

  def repository_folders(id:)
    tree = get("user/#{id}/repository/tree", { recursive: true })
    @repository_folders ||= tree.map(&:path)
  end
end

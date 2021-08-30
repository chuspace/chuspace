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
end

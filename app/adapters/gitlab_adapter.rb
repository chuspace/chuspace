# frozen_string_literal: true

class GitlabAdapter
  include FaradayClient::Connection

  attr_reader :endpoint, :access_token
  delegate :username, to: :user

  def initialize(endpoint:, access_token:)
    @endpoint = endpoint
    @access_token = access_token
  end

  def name
    'gitlab'
  end

  def current_user
    @current_user ||= get('user')
  end

  def user(id:)
    @user ||= get("users/#{id}")
  end

  def create_user(email:, name:, username:)
    post(
      'users',
      {
        email: email,
        name: name,
        username: username,
        projects_limit: 100,
        can_create_group: false,
        private_profile: true,
        skip_confirmation: true,
        force_random_password: true
      }
    )
  end

  def deactivate_user(id:)
    post("users/#{id}/deactivate")
  end

  def repository(id:)
    @repository ||= get("projects/#{id}")
  end

  alias repo repository

  def repositories(options: {})
    @repositories ||= paginate("users/#{username}/projects", options)
  end

  alias repos repositories

  def create_repository(user_id:, name:, description:, visibility: :private, template_name: :hugo)
    post(
      "projects/user/#{user_id}",
      {
        name: name,
        description: description,
        visibility: visibility,
        template_name: template_name
      }
    )
  end

  alias create_repo create_repository
end

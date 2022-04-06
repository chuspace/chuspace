# frozen_string_literal: true

class GitProvider < ApplicationRecord
  class GitAdapterNotFoundError < StandardError; end

  belongs_to :user
  encrypts :access_token, :refresh_access_token, :api_endpoint,
           :client_id, :client_secret, :refresh_access_token_endpoint

  validates :name, :label, :api_endpoint, :client_id, :client_secret, presence: true
  validates :name, uniqueness: { scope: :user_id }

  enum name: GitStorageConfig.providers_enum

  def connected?
    expiring? ? access_token_expires_at > Time.current.utc : access_token.present?
  end

  def config
    GitStorageConfig.new.send(name)
  end

  def expiring?
    refresh_access_token.present?
  end

  def adapter
    options = { access_token: access_token, endpoint: api_endpoint, access_token_param: access_token_param }

    case name
    when 'github' then GithubAdapter.new(**options)
    when 'gitea' then GiteaAdapter.new(**options)
    when 'gitlab' then GitlabAdapter.new(**options)
    else fail GitAdapterNotFoundError, "#{name} adapter not found"
    end
  end

  def to_param
    name
  end

  def users
    adapter.users
  end
end

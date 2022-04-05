# frozen_string_literal: true

class GitProvider < ApplicationRecord
  class GitAdapterNotFoundError < StandardError; end

  belongs_to :user
  encrypts :access_token, :refresh_access_token, :endpoint,
           :client_id, :client_secret, :refresh_access_token_endpoint

  validates :name, :label, :client_id, :client_secret, presence: true
  validates :name, uniqueness: { scope: :user_id }

  enum name: GitStorageConfig.providers_enum

  def api
    HTTPAdapter.new(
      access_token: access_token,
      endpoint: api_endpoint,
      access_token_param: access_token_param
    )
  end

  def connected?
    expiring? ? access_token_expires_at > Time.current.utc : access_token.present?
  end

  def config
    GitStorageConfig.new.send(name)
  end

  def expiring?
    refresh_access_token.present?
  end

  def mirror_api
    access_token = Rails.application.credentials.chuspace.git_mirror[:access_token]
    HTTPAdapter.new(endpoint: mirror_api_endpoint, access_token: access_token, access_token_param: :token)
  end

  def mirror_api_endpoint
    Rails.application.credentials.chuspace.git_mirror[:endpoint]
  end

  def refreshable?
    refresh_access_token.present?
  end

  def refresh_access_token!
    RefreshAccessTokenJob.perform_later(git_provider: self)
  end

  def to_param
    name
  end

  def users
    adapter.users
  end
end

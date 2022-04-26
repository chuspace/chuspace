# frozen_string_literal: true

class GitProvider < ApplicationRecord
  class GitAdapterNotFoundError < StandardError; end

  belongs_to :user
  encrypts :access_token, :refresh_access_token, :api_endpoint,
           :client_id, :client_secret, :refresh_access_token_endpoint

  validates :name, :label, :api_endpoint, :client_id, :client_secret, presence: true
  validates :name, uniqueness: { scope: :user_id }

  store_accessor :client_options, :site, :authorize_url, :token_url

  enum name: GitStorageConfig.providers_enum

  def connected?
    expiring? ? access_token_expires_at > Time.current.utc : access_token.present?
  end

  def config
    GitStorageConfig.new.send(name)
  end

  def expiring?
    access_token_expires_at.present?
  end

  def adapter
    # Implement adapters here
    GithubAdapter.new(git_provider: self)
  end

  def to_param
    name
  end

  def users
    adapter.users
  end
end

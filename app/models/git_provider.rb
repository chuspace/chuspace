# frozen_string_literal: true

class GitProvider < ApplicationRecord
  class GitAdapterNotFoundError < StandardError; end

  belongs_to :user

  encrypts :user_access_token, :api_endpoint, :client_id, :client_secret
  validates :name, :label, :api_endpoint, :client_id, :client_secret, presence: true
  validates :name, uniqueness: { scope: :user_id }
  validates :name, uniqueness: { scope: :app_installation_id }

  store_accessor :client_options, :site, :authorize_url, :token_url

  enum name: GitStorageConfig.providers_enum

  def adapter
    case name.to_sym
    when :github then GithubAdapter.new(git_provider: self)
    else fail GitAdapterNotFoundError, 'Adapter not implemented'
    end
  end

  def connected?
    expiring? && user_access_token_expires_at > Time.current.utc
  end

  def config
    GitStorageConfig.new.send(name)
  end

  def expiring?
    user_access_token.present? && user_access_token_expires_at.present?
  end

  def revoke!
    update(app_installation_id: nil, user_access_token: nil, machine_access_token: nil, user_access_token_expires_at: nil)
  end

  def to_param
    name
  end

  def users
    adapter.users
  end
end

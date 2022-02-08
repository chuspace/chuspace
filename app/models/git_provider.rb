# frozen_string_literal: true

class GitProvider < ApplicationRecord
  class GitAdapterNotFoundError < StandardError; end

  belongs_to :user
  encrypts :access_token, :refresh_access_token, :endpoint

  validates :name, :label, presence: true
  validates :name, uniqueness: { scope: :user_id }
  validates :refresh_access_token, :expires_at, presence: true, if: :access_token

  enum name: GitStorageConfig.providers_enum

  def connected?
    access_token.present? && expires_at > Time.current
  end

  def users
    adapter.users
  end

  def adapter
    case name
    when 'github', 'github_enterprise', 'gitea' then GithubAdapter.new(access_token: access_token, endpoint: endpoint)
    when 'gitlab', 'gitlab_foss' then GitlabAdapter.new(access_token: access_token, endpoint: endpoint)
    else fail GitAdapterNotFoundError, "#{name} adapter not found"
    end
  end

  def to_param
    name
  end
end

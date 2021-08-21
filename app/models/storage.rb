# frozen_string_literal: true

class Storage < ApplicationRecord
  belongs_to :user
  encrypts :access_token, :endpoint

  validates :description, :provider, :access_token, presence: true
  validates :provider, uniqueness: { scope: :user_id, message: :one_provider_per_user }

  enum provider: GitStorageConfig.providers_enum

  before_validation :set_endpoint, on: :create

  def connected?
    true
    #  Add logic
  end

  def api
    @api ||= client
  end

  private

  def set_endpoint
    self.endpoint ||= GitStorageConfig.new.send(provider).dig(:endpoint)
  end

  def client
    case provider.to_sym
    when :github
      Octokit::Client.new(access_token: access_token, api_endpoint: endpoint)
    when :gitlab
      Gitlab.client(
        endpoint: endpoint,
        private_token: access_token,
        httparty: {
          headers: { 'Cookie' => 'gitlab_canary=true' }
        }
      )
    when :bitbucket
    end
  end
end

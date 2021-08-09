# frozen_string_literal: true

class Storage < ApplicationRecord
  belongs_to :user
  encrypts :access_token

  SCOPES = {
    github: ['admin:repo_hook', 'repo', 'workflow']
  }.with_indifferent_access.freeze

  enum provider: {
    github: 'github',
    gitlab: 'gitlab',
    bitbucket: 'bitbucket'
  }

  class << self
    def available_providers
      Storage.providers.values - Storage.pluck(:provider)
    end
  end

  def connected?
    SCOPES[provider] == api.scopes
  end

  def api
    @api ||= Octokit::Client.new(access_token: access_token)
  end
end

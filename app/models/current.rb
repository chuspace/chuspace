# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :user, :github_client
  attribute :request_id, :user_agent, :ip_address

  def user=(user)
    self.github_client ||= Octokit::Client.new(access_token: Current.user.token) if Current.user.present?

    super
  end
end

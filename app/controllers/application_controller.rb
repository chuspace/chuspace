# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ParamsSanitizer
  include Authentication
  include SetCurrentRequestDetails
  include SetSentryContext

  before_action :github_client, if: :signed_in?

  private

  def github_client
    @github_client ||= Octokit::Client.new(access_token: Current.user.token)
  end
end

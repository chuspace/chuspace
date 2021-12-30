# frozen_string_literal: true

module GitProviders
  class ReposController < ApplicationController
    before_action :authenticate!, :find_git_provider

    def index
      query = "#{params[:query]} fork:true user:#{params[:login]}"
      @repositories = @git_provider.adapter.search_repositories(query: query)

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(helpers.dom_id(@git_provider, :repositories), partial: "repositories", locals: { repositories: @repositories, provider: @git_provider })}
        format.html
      end
    end

    private

    def find_git_provider
      @git_provider = Current.user.git_providers.find_by(name: params[:git_provider_id])
    end
  end
end

# frozen_string_literal: true

module Github
  class ReposController < ApplicationController
    def index
      @repositories = github_client.search_repos("#{params[:q]} user:#{User.first.username}", query: { sort: 'asc', per_page: 5 }).items

      respond_to do |format|
        format.json
        format.html_fragment
      end
    end
  end
end

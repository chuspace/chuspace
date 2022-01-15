# frozen_string_literal: true

module Connect
  class BaseController < ApplicationController
    before_action :authenticate!, :find_git_provider, :build_publication

    def index
      @git_providers = Current.user.git_providers
    end

    def show
      @git_provider_user ||= @git_provider.adapter.user
    end

    def users
      render partial: 'connect/shared/users', locals: { git_provider_users: @git_provider.users }
    end

    def repos
      login = params[:login] || @git_provider.adapter.user.login
      query = "#{params[:query]} user:#{login}"
      @repositories = @git_provider.adapter.search_repositories(query: query)

      render(
        turbo_stream: turbo_stream.replace(
          helpers.dom_id(@git_provider, :repositories),
          partial: 'connect/shared/repos',
          locals: {
            publication: @publication,
            repositories: @repositories,
            provider: @git_provider
          }
        )
      )
    end

    def create
      @publication.assign_attributes(publication_params)

      if @publication.save!
        redirect_to user_publication_path(@publication.owner, @publication)
      else
        respond_to do |format|
          format.html
          format.turbo_stream {
            render(
              turbo_stream: turbo_stream.replace(
                @publication,
                partial: 'publications/form',
                locals: {
                  publication: @publication,
                  url: create_publication_path
                }
              )
            )
          }
        end
      end
    end

    private

    def publication_params
      params.require(:publication).permit(
        :name,
        :description,
        repo_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end

    def build_publication
      @publication = Current.user.owning_publications.build(git_provider: @git_provider)
      @publication.build_repo(fullname: params[:repo_fullname])
    end

    def find_git_provider
      @git_provider = Current.user.git_providers.find_by(name: params[:git_provider])
    end
  end
end

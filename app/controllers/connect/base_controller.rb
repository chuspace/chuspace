# frozen_string_literal: true

module Connect
  class BaseController < ApplicationController
    before_action :authenticate!
    before_action :find_git_provider
    before_action :build_publication

    skip_verify_authorized

    def new
      if turbo_frame_request?
        render partial: 'form',
locals: { folders: @publication.repository.folders, markdown_files: @publication.repository.markdown_files, publication: @publication }
      end
    end

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
      @repositories = @git_provider.adapter.search_repositories(query: params[:query], login: params[:login])

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

      if @publication.save
        redirect_to @publication.personal? ? user_path(@publication.owner) : publication_path(@publication)
      else
        respond_to do |format|
          format.html
          format.turbo_stream {
            render(
              turbo_stream: turbo_stream.replace(
                @publication,
                partial: partial_name,
                locals: {
                  publication: @publication,
                  folders: @publication.repository.folders,
                  markdown_files: @publication.repository.markdown_files,
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
        repository_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end

    def build_publication
      @publication = Current.user.owning_publications.build(git_provider: @git_provider)
      @publication.build_repository(git_provider: @git_provider, full_name: params[:repo_fullname])

      fail ActiveRecord::RecordNotFound if @git_provider && params[:repo_fullname] && @publication.repository.blank?
    end

    def find_git_provider
      @git_provider = Current.user.git_providers.find_by(name: params[:git_provider])
    rescue ActiveRecord::StatementInvalid
      fail ActiveRecord::RecordNotFound
    end
  end
end

# frozen_string_literal: true

module Connect
  class PersonalPublicationsController < BaseController
    before_action :check_personal_publication_existence!, :set_as_personal_publication # Depends on Connectable

    private

    def create_publication_path
      create_connect_personal_publication_path(@git_provider, repo_fullname: @publication.repo.fullname)
    end

    def publication_params
      params.require(:publication).permit(
        repo_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end

    def set_as_personal_publication
      @publication.name = Current.user.username
      @publication.personal = true
    end

    def partial_name
      'connect/personal_publications/form'
    end

    def check_personal_publication_existence!
      redirect_to connect_root_path, notice: t('connect.personal_publications.exists') if Current.user.personal_publication.present?
    end
  end
end

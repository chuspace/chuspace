# frozen_string_literal: true

module Publications
  class SettingsController < BaseController
    skip_before_action :authenticate!, only: :show

    PARTIALS = %w[profile content front_matter permissions].freeze

    def index
      authorize! @publication, to: :edit?

      redirect_to publication_setting_path(@publication, id: PublicationSettings::DEFAULT_PAGE)
    end

    def show
      @partial = params[:id]
      authorize! @publication, to: :edit?

      add_breadcrumb('Settings', publication_settings_path(@publication))
      add_breadcrumb(@partial.humanize)

      fail ActiveRecord::RecordNotFoundError if PublicationSettings::PAGES.exclude?(@partial)
    end

    def update
      authorize! @publication, to: :edit?
      @publication.update(publication_params)

      redirect_to publication_setting_path(@publication, id: params[:id])
    end

    private

    def publication_params
      params.require(:publication).permit(
        :name,
        :description,
        repo_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end
  end
end

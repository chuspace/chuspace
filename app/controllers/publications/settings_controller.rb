# frozen_string_literal: true

module Publications
  class SettingsController < BaseController
    def index
      authorize! @publication, to: :edit?

      redirect_to publication_setting_path(@publication, id: PublicationSetting::DEFAULT_PAGE)
    end

    def show
      @partial = params[:id]
      authorize! @publication, to: :edit?

      add_breadcrumb(t("publications.settings.show.#{@partial}.title"))

      fail ActiveRecord::RecordNotFoundError if PublicationSetting::PAGES.exclude?(@partial)
    end

    def update
      authorize! @publication, to: :edit?
      @publication.update(publication_params)

      redirect_to @publication.personal? ? setting_path(id: params[:id]) : publication_setting_path(@publication, id: params[:id])
    end

    private

    def publication_params
      params.require(:publication).permit(
        :name,
        :description,
        :icon,
        :visibility,
        :twitter_handle,
        repository_attributes: %i[auto_publish posts_folder drafts_folder assets_folder readme_path id],
        content_attributes: %i[auto_publish id],
        front_matter_attributes: %i[title summary date topics id]
      )
    end
  end
end

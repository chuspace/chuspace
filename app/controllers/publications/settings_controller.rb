# frozen_string_literal: true

module Publications
  class SettingsController < ApplicationController
    before_action :authenticate!, except: :show
    PARTIALS = %w[profile content front_matter permissions].freeze

    def index
      @user = Current.user
      @publication = Publication.friendly.find(params[:publication_permalink])
      redirect_to publication_setting_path(@publication, id: PublicationSettings::DEFAULT_PAGE)
    end

    def show
      @user = Current.user
      @publication = Publication.friendly.find(params[:publication_permalink])
      @partial = params[:id]

      fail ActiveRecord::RecordNotFoundError if PublicationSettings::PAGES.exclude?(params[:id])
    end

    def update
      @user = Current.user
      @publication = Publication.friendly.find(params[:publication_permalink])
      @publication.update(publication_params)

      redirect_to publication_setting_path(@publication, id: params[:id])
    end

    def publication_params
      params.require(:publication).permit(
        :name,
        :description,
        repo_attributes: %i[posts_folder drafts_folder assets_folder readme_path]
      )
    end
  end
end

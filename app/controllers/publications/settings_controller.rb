# frozen_string_literal: true

module Publication
  class SettingsController < ApplicationController
    before_action :authenticate!, except: :show
    before_action :set_content_partial, only: :show

    def index
      @user = Current.user
      @publication = Blog.friendly.find(params[:publication_permalink])
    end

    def update
      @user = Current.user
      @publication = Blog.friendly.find(params[:publication_permalink])
      @publication.update(publication_params)
    end

    def publication_params
      params.require(:publication).permit(:front_matter_attributes_map)
    end
  end
end

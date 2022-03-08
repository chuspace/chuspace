# frozen_string_literal: true

module Posts
  class ReactionsController < ApplicationController
    before_action :authenticate!
    before_action :find_publication, :find_post
    layout false

    def index
      authorize! @post
    end

    private

    def find_post
      @post = @publication.posts.friendly.find(params[:post_permalink])
    end

    def find_publication
      @publication = Publication.friendly.find(params[:publication_permalink])
    end
  end
end

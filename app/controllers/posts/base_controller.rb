# frozen_string_literal: true

module Posts
  class BaseController < ApplicationController
    before_action :authenticate!
    before_action :find_publication, :find_post

    private

    def find_post
      @post = @publication.posts.friendly.find(params[:post_permalink])
    end

    def find_publication
      @publication = Publication.friendly.find(params[:publication_permalink])
    end
  end
end

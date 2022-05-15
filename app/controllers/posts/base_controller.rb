# frozen_string_literal: true

module Posts
  class BaseController < ApplicationController
    before_action :authenticate!
    include FindPublication
    before_action :find_post

    private

    def find_post
      @post = @publication.posts.unscoped.friendly.find(params[:post_permalink])
    end
  end
end

# frozen_string_literal: true

module Settings
  class ProfilesController < ApplicationController
    layout 'settings'
    before_action :find_blog, only: :edit

    def index
    end

    def edit
      render 'blogs/edit'
    end

    private

    def find_blog
      @blog = Current.user.blogs.find(params[:id])
    end
  end
end
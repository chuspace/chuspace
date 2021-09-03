module Settings
  class BlogsController < ApplicationController
    layout 'settings'
    before_action :find_blog, only: :edit



    private

    def find_blog
      @blog = Current.user.blogs.find(params[:id])
    end
  end
end

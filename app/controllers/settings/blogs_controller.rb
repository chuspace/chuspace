module Settings
  class BlogsController < ApplicationController
    layout 'settings'
    before_action :find_blog, only: :edit

    def new
      @blog = Current.user.blogs.build(storage: Current.user.storages.default_or_chuspace)
    end

    def connect
      @blog = Current.user.blogs.new(storage: Current.user.storages.default)
    end

    private

    def find_blog
      @blog = Current.user.blogs.find(params[:id])
    end
  end
end

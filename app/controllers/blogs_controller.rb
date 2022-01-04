# frozen_string_literal: true

class BlogsController < ApplicationController
  include AutoCheckable

  before_action :authenticate!, except: :show
  before_action :set_content_partial, only: :show

  def auto_check
    check_resource_available(resource: Current.user.blogs.new(name: params[:value]), attribute: :name)
  end

  def show
    @blog = Blog.friendly.find(params[:permalink])

    if @blog.personal?
      redirect_to user_path(@blog.owner)
    end
  end

  private

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'blogs/form'
               when 'posts' then 'blogs/posts'
               when 'drafts' then 'blogs/drafts'
    else 'blogs/about'
    end
  end
end

# frozen_string_literal: true

class BlogsController < ApplicationController
  include AutoCheckable

  before_action :authenticate!, except: :show
  before_action :find_blog, except: %i[new connect create index auto_check]
  before_action :set_content_partial, only: :show

  def index
    @blogs = Current.user.blogs
  end

  def new
    if Current.user.storages.chuspace.present?
      @blog = Current.user.blogs.build(owner: Current.user, storage: Current.user.storages.chuspace)
    else
      redirect_to storages_path, notice: 'You do not have any git storages configured'
    end
  end

  def connect
    @blog = Current.user.blogs.build
  end

  def create
    @blog = Current.user.blogs.build(
      blog_params.merge(
        owner_id: Current.user.id,
        members_attributes: {
          user_id: Current.user.id,
          role: :owner
        }
      )
    )

    if @blog.save && params[:commit] == 'Connect'
      redirect_to user_blog_path(Current.user, @blog)
    else
      puts @blog.errors.inspect
      puts 'errors'
      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@blog, partial: "blogs/#{params[:type]}", locals: { blog: @blog }) }
      end
    end
  end

  def auto_check
    check_resource_available(resource: Current.user.blogs.new(name: params[:value]), attribute: :name)
  end

  def show
    if @blog.personal?
      redirect_to user_path(@blog.owner)
    end
  end

  def update
    @blog.update!(blog_params)

    redirect_to blogs_path
  end

  def destroy
    @blog.destroy
    redirect_to blogs_path
  end

  private

  def blog_params
    params.require(:blog).permit(
      :name,
      :description,
      :storage_id,
      :template_id,
      :visibility,
      :repo_posts_folder,
      :repo_drafts_folder,
      :repo_assets_folder,
      :repo_fullname,
      :repo_readme_path,
      :personal
    )
  end

  def find_blog
    @blog = Current.user.blogs.friendly.find(params[:permalink])
  end

  def set_content_partial
    @partial = case params[:tab]
               when 'settings' then 'blogs/form'
               when 'posts' then 'blogs/posts'
               when 'drafts' then 'blogs/drafts'
    else 'blogs/about'
    end
  end
end

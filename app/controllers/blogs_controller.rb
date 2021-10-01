# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate!, except: :show
  before_action :find_blog, except: %i[new connect create index]

  def new
    if Current.user.storages.chuspace.present?
      @blog = Current.user.blogs.build(storage: Current.user.storages.chuspace)

      render 'index'
    else
      redirect_to storages_path, notice: 'You do not have any git storages configured'
    end
  end

  def connect
    @blog = Current.user.blogs.new(storage: Current.user.storages.first)
    render 'index'
  end

  def create
    @blog = Current.user.blogs.new(blog_params)

    if @blog.save
      redirect_to blogs_path
    else
      @blog.errors.clear

      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@blog, partial: "blogs/#{params[:type]}", locals: { blog: @blog }) }
      end
    end
  end

  def show
    @articles = @blog.articles
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
      :framework,
      :visibility,
      :repo_articles_folder,
      :repo_drafts_folder,
      :repo_assets_folder,
      :repo_fullname
    )
  end

  def find_blog
    @blog = Current.user.blogs.find(params[:id])
  end
end

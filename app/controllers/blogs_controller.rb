# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate!, except: :show
  before_action :find_blog, except: %i[new connect create index]

  def new
    @blog = Current.user.blogs.build(storage: Current.user.storages.default_or_chuspace)
  end

  def connect
    @blog = Current.user.blogs.new(storage: Current.user.storages.default)
  end

  def create
    @blog = Current.user.blogs.new(blog_params)

    if @blog.save
      redirect_to settings_blogs_path
    else
      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@blog, partial: 'blogs/form', locals: { blog: @blog, type: params[:type] }) }
      end
    end
  end

  def show
    @articles = @blog.articles
  end

  def update
    @blog.update!(blog_params)
    redirect_to settings_blogs_path
  end

  def destroy
    @blog.destroy
    redirect_to settings_blogs_path
  end

  private

  def blog_params
    params.require(:blog).permit(:name, :description, :storage_id, :framework, :git_repo_id, :visibility, :posts_folder, :drafts_folder, :assets_folder)
  end

  def find_blog
    @blog = Current.user.blogs.find(params[:id])
  end
end

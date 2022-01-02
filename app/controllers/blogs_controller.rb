# frozen_string_literal: true

class BlogsController < ApplicationController
  include AutoCheckable

  before_action :authenticate!, except: :show
  before_action :find_blog, only: %i[show update edit destroy]
  before_action :find_git_provider, only: %i[new connect]
  before_action :set_content_partial, only: :show

  def new
    @blog = Current.user.owning_blogs.build
    @blog.git_provider = @git_provider
    @blog.repo_fullname = params[:repo_fullname]

    if @blog.repo_fullname.present?
      render 'blogs/new/settings'
    elsif @blog.git_provider.present?
      render 'blogs/new/git_repo'
    else
      render 'blogs/new/git_provider'
    end
  end

  def connect
    @blog = Current.user.owning_blogs.build
    @blog.git_provider = @git_provider
    @blog.repo_fullname = params[:repo_fullname]

    if @blog.repo_fullname.present? && @blog.repository.instance.present?
      render 'blogs/connect/settings'
    elsif @blog.git_provider.present?
      flash[:notice] = "Repository not found: #{@blog.repo_fullname}" if @blog.repo_fullname.present?
      render 'blogs/connect/git_repo'
    else
      render 'blogs/connect/git_provider'
    end
  end

  def create
    @blog = Current.user.owning_blogs.build(blog_params.delete_if { |key, value| value.blank? })

    if @blog.save && @blog.memberships.create(user: @blog.owner, role: :owner)
      redirect_to user_blog_path(@blog.owner, @blog)
    else
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

    redirect_to user_blogs_path(@blog.owner, @blog), notice: 'Successfully updated!'
  end

  def destroy
    @blog.destroy
    redirect_to user_blogs_path(@blog.owner, @blog), notice: 'Successfully deleted!'
  end

  private

  def blog_params
    params.require(:blog).permit(
      :name,
      :description,
      :git_provider_id,
      :visibility,
      :repo_posts_dir,
      :repo_drafts_dir,
      :repo_assets_dir,
      :repo_fullname,
      :repo_readme_path,
      :personal
    )
  end

  def find_blog
    @blog = Blog.friendly.find(params[:permalink])
  end

  def find_git_provider
    if GitProvider.names.keys.include?(params[:git_provider])
      @git_provider = Current.user.git_providers.send(params[:git_provider])&.first
    end
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

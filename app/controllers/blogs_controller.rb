# frozen_string_literal: true

class BlogsController < ApplicationController
  before_action :authenticate!, except: :show

  def new
    @blog = Current.user.blogs.build(storage: Current.user.storages.default_or_internal)
    @repo_folders = []
  end

  def create
    if params[:blog][:type] == 'connect'
      @blog = Current.user.blogs.new(connect_blog_params)
      @repo_folders = []

      begin
        repo_sha = github_client.commits(@blog.full_repo_name).first.sha
        tree = github_client.tree(@blog.full_repo_name, repo_sha, recursive: true).tree
        @repo_folders = tree.select { |item| item.type == 'tree' }.map(&:path).sort
      rescue Octokit::Conflict
      end
    elsif params[:blog][:type] == 'new'
      repo = github_client.create_repository_from_template('gauravtiwari/blog-template', params[:blog][:name], accept: Octokit::Preview::PREVIEW_TYPES[:template_repositories], private: params[:blog][:private] == 'true', **create_blog_params)
      @blog = Current.user.blogs.new(full_repo_name: repo.full_name, posts_folder: 'src/pages/posts', drafts_folder: 'src/pages/posts', assets_folder: 'public/assets/blog')
    end

    if @blog.save
      respond_to do |format|
        format.html { redirect_to root_path }
        format.turbo_stream { redirect_to root_path }
      end
    else
      @blog = Current.user.blogs.new(connect_blog_params)

      respond_to do |format|
        format.html
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@blog, partial: 'blogs/form', locals: { blog: @blog, type: :connect, repo_folders: @repo_folders }) }
      end
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def connect_blog_params
    params.require(:blog).permit(:full_repo_name, :posts_folder, :drafts_folder, :assets_folder)
  end

  def create_blog_params
    params.require(:blog).permit(:description, :owner)
  end
end

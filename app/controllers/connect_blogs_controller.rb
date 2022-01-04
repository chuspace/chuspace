# frozen_string_literal: true

class ConnectBlogsController < ApplicationController
  before_action :authenticate!, except: :show
  before_action :find_git_provider
  before_action :build_blog

  def index
  end

  def choose_git_repo
  end

  def finalise_settings
  end

  def create
    @blog.assign_attributes(connect_blog_params.delete_if { |key, value| value.blank? })

    if @blog.save && @blog.memberships.create(user: @blog.owner, role: :owner)
      redirect_to user_blog_path(@blog.owner, @blog)
    else
      respond_to do |format|
        format.html
        format.turbo_stream {
          render(
            turbo_stream: turbo_stream.replace(
              @blog,
              partial: 'blogs/form',
              locals: {
                blog: @blog,
                url: create_connect_blog_path(git_provider: @git_provider.name, repo_fullname: @blog.repo_fullname)
              }
            )
          )
        }
      end
    end
  end

  private

  def connect_blog_params
    params.require(:blog).permit(
      :name,
      :description,
      :visibility,
      :repo_posts_dir,
      :repo_drafts_dir,
      :repo_assets_dir,
      :repo_readme_path,
      :personal
    )
  end

  def build_blog
    @blog = Current.user.owning_blogs.build
    @blog.git_provider = @git_provider
    @blog.repo_fullname = params[:repo_fullname]
  end

  def find_git_provider
    @git_provider = Current.user.git_providers.find_by(name: params[:git_provider])
  end
end

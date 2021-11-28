# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :find_user, :find_blog
  layout 'editor'

  def show
    @post = @blog.posts.joins(:revisions).find_by(revisions: { sha: params[:id] })
  end

  private

  def find_blog
    @blog = @user.blogs.friendly.find(params[:blog_permalink])
  end

  def find_user
    @user = User.friendly.find(params[:user_username])
  end

  def post_params
    params.require(:post).permit(:content)
  end
end

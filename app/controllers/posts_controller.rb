# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :find_user, :find_blog
  layout 'editor', only: %i[new edit]

  def new
    @post = @blog.posts.new
    @post.revisions.build(author: Current.user, blog: @blog)
  end

  def edit
    @post = @blog.posts.joins(:revisions).find_by(revisions: { sha: params[:id] })
  end

  def show
    @post = @blog.posts.joins(:editions).find_by(editions: { permalink: params[:permalink] })
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

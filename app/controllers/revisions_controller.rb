# frozen_string_literal: true

class RevisionsController < ApplicationController
  before_action :find_user, :find_blog, :find_post
  layout false

  def new
    @revision = @post.revisions.build(
      author: Current.user,
      blog: @blog
    )
  end

  def create
    revision = @post.revisions.create(
      author: Current.user,
      blog: @blog,
      **revision_params
    )

    redirect_to edit_user_blog_post_path(@user, @blog, revision)
  end

  private

  def find_post
    @post = @blog.posts.joins(:revisions).find_by(revisions: { sha: params[:post_permalink] })
  end

  def find_blog
    @blog = @user.blogs.friendly.find(params[:blog_permalink])
  end

  def find_user
    @user = User.friendly.find(params[:user_username])
  end

  def revision_params
    params.require(:revision).permit(:message, :content)
  end
end

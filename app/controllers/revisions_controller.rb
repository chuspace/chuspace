# frozen_string_literal: true

class RevisionsController < ApplicationController
  before_action :find_user, :find_blog, :find_post
  layout false

  def create
    revision = @post.revisions.create(
      committer: Current.user,
      originator: :chuspace,
      message: revision_params[:message],
      content: <<~STR
        ---
        #{@post.revisions.current.front_matter_str(title: revision_params[:title])}
        ---

        #{revision_params[:content]}
      STR
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
    params.require(:revision).permit(:message, :title, :content)
  end
end

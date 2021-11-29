# frozen_string_literal: true

class DraftsController < ApplicationController
  before_action :find_user, :find_blog
  layout 'editor'

  def edit
    @edit = true
    @post = @blog.posts.joins(:revisions).find_by(revisions: { sha: params[:sha] })
  end

  private

  def find_blog
    @blog = @user.blogs.friendly.find(params[:blog_permalink])
  end

  def find_user
    @user = User.friendly.find(params[:user_username])
  end
end

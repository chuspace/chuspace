# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :find_user, :find_blog
  layout 'editor', only: %i[new edit]

  def new
    @post = @blog.posts.new(author: Current.user)
    @post.revisions.build(committer: Current.user)
  end

  def create
    @post = @blog.posts.build(author: Current.user, **post_params)
    @post.revisions.build(committer: Current.user, content: Post::DEFAULT_FRONT_MATTER)

    if @post.save
      redirect_to edit_user_blog_post_path(@post.blog.owner, @post.blog, @post.revisions.current)
    else
      respond_to do |format|
        @post.blob_path = File.basename(@post.blob_path || '', '*.md')
        format.html { render :new }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: 'posts/form', locals: { post: @post }) }
      end
    end
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
    params.require(:post).permit(:blob_path)
  end
end

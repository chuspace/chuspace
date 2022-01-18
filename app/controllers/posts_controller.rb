# frozen_string_literal: true

class PostsController < ApplicationController
  include Breadcrumbable

  before_action :find_user, :find_publication
  before_action :find_post, only: %i[show update destroy edit]

  layout 'editor', only: %i[new edit]

  def new
    @post = @publication.posts.new(author: Current.user)
  end

  def create
    @post = @publication.posts.build(author: Current.user, **post_params)

    if @post.save
      redirect_to edit_user_publication_post_path(@post.publication.owner, @post.publication, @post.revisions.current)
    else
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@post, partial: 'posts/form', locals: { post: @post }) }
      end
    end
  end

  private

  def find_post
    @post = @publication.posts.friendly.find(params[:permalink])
  end

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])
  end

  def post_params
    params.require(:post).permit(:blob_path)
  end
end

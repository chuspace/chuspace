# frozen_string_literal: true

class PostsController < ApplicationController
  include Breadcrumbable, FindPublication

  before_action :find_post, only: %i[show update destroy edit]
  after_action :track_action, only: :show
  skip_verify_authorized only: :show

  layout 'post'

  private

  def track_action
    ahoy.track 'Viewed post', request.path_parameters.merge(post_id: @post.id, publication_id: @publication.id)
  end

  def find_post
    @post = Post.friendly.find(params[:permalink])

    if params[:permalink] != @post.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@post), status: :moved_permanently
    end
  end
end

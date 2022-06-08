# frozen_string_literal: true

class PostsController < ApplicationController
  include Breadcrumbable, FindPublication

  before_action :find_post, only: %i[show update destroy edit]
  after_action :track_action, only: :show
  skip_verify_authorized only: :show

  layout 'post'

  def show
    fresh_when(etag: @post, last_modified: [Current.identity&.updated_at, @post.updated_at].compact.max)
  end

  private

  def track_action
    ActiveRecord::Base.connected_to(role: :writing) do
      ahoy.track 'view:post', request.path_parameters.merge(post_id: @post.id, publication_id: @publication.id)
    end
  end

  def find_post
    @post = Post.friendly.find(params[:permalink])

    if params[:permalink] != @post.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@post), status: :moved_permanently
    end
  end
end

# frozen_string_literal: true

module FindPost
  extend ActiveSupport::Concern

  included do
    before_action :find_post
  end

  private

  def find_post
    @post = @publication.posts.friendly.find(params[:post_permalink])

    if params[:publication_permalink] != @publication.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@post), status: :moved_permanently
    end

    add_breadcrumb(@post.permalink, publication_path(@post))
  end
end

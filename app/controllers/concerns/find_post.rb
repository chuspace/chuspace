# frozen_string_literal: true

module FindPost
  extend ActiveSupport::Concern

  included do
    before_action :find_post
  end

  private

  def find_post
    @post = Post.friendly.find(params[:post_permalink])
    if params[:post_permalink] != @post.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@post), status: :moved_permanently
    end
    add_breadcrumb(@post.permalink, post_publication_path(@publication, @post))
  end
end

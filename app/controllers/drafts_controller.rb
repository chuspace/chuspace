# frozen_string_literal: true

class DraftsController < ApplicationController
  before_action :find_blog
  layout 'editor'

  def new
    @blob = Blob.new(blog: @blog)
  end

  def edit
    @article = @blog.drafts.find(params[:id])
    @edit = true
    @markdown_doc ||= CommonMarker.render_doc(@article.content || '')
  end

  private

  def find_blog
    @blog = Current.user.blogs.friendly.find(params[:blog_id])
  end

  def draft_params
    params.require(:draft).permit(:content)
  end
end

# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :find_blog

  def index
    @blob = @blog.git_blob(path: params[:path])

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  private

  def find_blog
    @blog = Current.user.blogs.find(params[:blog_id])
  end
end

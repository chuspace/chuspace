# frozen_string_literal: true

require 'marcel'

class AssetsController < ApplicationController
  include ActiveStorage::Streaming
  before_action :find_blog

  def index
    @blob = @blog.repository.blobs.images.find_by(path: CGI.unescape(params[:path]))

    http_cache_forever(public: true) do
      send_blob_stream @blob.content, disposition: params[:disposition]
    end
  end

  private

  def find_blog
    @blog = Blog.friendly.find(params[:blog_id])
  end
end

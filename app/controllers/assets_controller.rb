# frozen_string_literal: true

class AssetsController < ApplicationController
  include ActiveStorage::Streaming
  before_action :find_blog

  def index
    @blob = @blog.repository_blob(path: CGI.unescape(params[:path]))

    http_cache_forever(public: true) do
      send_blob_stream Base64.decode64(@blob.content), disposition: params[:disposition]
    end
  end

  private

  def find_blog
    @blog = Blog.friendly.find(params[:blog_id])
  end
end

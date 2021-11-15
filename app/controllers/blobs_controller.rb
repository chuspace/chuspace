# frozen_string_literal: true

require 'marcel'

class BlobsController < ApplicationController
  before_action :find_blog

  def index
    @blob = @blog.asset(path: params[:path])
    mime_type = Marcel::MimeType.for name: File.basename(@blob.path)
    send_data Base64.decode64(@blob.content), type: mime_type, disposition: 'inline'
  end

  private

  def find_blog
    @blog = Current.user.blogs.find_by(permalink: params[:blog_id])
  end
end

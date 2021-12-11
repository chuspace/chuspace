# frozen_string_literal: true

class FeedController < ApplicationController
  def index
    @posts = Post.published.limit(20)
  end
end

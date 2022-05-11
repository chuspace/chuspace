# frozen_string_literal: true

class TopicsController < ApplicationController
  skip_verify_authorized

  def index
    @topics = ActsAsTaggableOn::Tag.search_by_name(params[:q]).limit(10)
  end

  def show
    @topic = ActsAsTaggableOn::Tag.find_by(name: params[:id])
    @posts = Post.tagged_with(@topic.name)
  end
end

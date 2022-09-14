# frozen_string_literal: true

class TopicsController < ApplicationController
  skip_verify_authorized

  def index
    @topics = TagFilter.new.filter(ActsAsTaggableOn::Tag.all, params[:q])
  end

  def show
    @topic = ActsAsTaggableOn::Tag.find_by(name: params[:id])
    @posts = Post.tagged_with(@topic.name)
  end
end

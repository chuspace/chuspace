# frozen_string_literal: true

class CommitsController < ApplicationController
  before_action :find_blog
  layout false

  def new
    @article = Article.new
    @edit = true
  end

  private

  def find_blog
    @blog = Current.user.blogs.find(params[:blog_id])
  end
end

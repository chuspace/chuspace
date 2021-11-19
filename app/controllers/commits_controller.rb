# frozen_string_literal: true

class CommitsController < ApplicationController
  before_action :find_blog
  before_action :find_article, only: %i[edit update destroy]
  layout false

  def new
    @article = Article.new
    @edit = true
  end

  def edit
  end

  private

  def find_blog
    @blog = Current.user.blogs.friendly.find(params[:blog_id])
  end

  def find_article
    @article = @blog.article(id: params[:id])
  end
end

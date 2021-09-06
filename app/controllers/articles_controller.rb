# frozen_string_literal: true

class ArticlesController < ApplicationController
  before_action :find_blog

  def new
  end

  def show
    @article = @blog.article(id: params[:id])
    @markdown_doc ||= CommonMarker.render_doc(@article.content || '')
  end

  def index
    @articles = @blog.articles
  end

  def edit
    @article = @blog.article(id: params[:id])
    @markdown_doc ||= CommonMarker.render_doc(@article.content || '')
  end

  def create
  end

  private

  def find_blog
    @blog = Current.user.blogs.find(params[:blog_id])
  end
end

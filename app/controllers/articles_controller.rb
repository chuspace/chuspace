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
    frontmatter = {
      'title' => article_params[:title],
      'date' => Date.today
    }.to_yaml

    @blog.create_draft_article(title: article_params[:title], content: frontmatter + "--- \n\n" + article_params[:content])
    redirect_to blog_path(@blog)
  end

  def destroy
    @blog.delete_article(id: params[:id], path: params[:path])
    redirect_to blog_path(@blog)
  end

  private

  def find_blog
    @blog = Current.user.blogs.find(params[:blog_id])
  end

  def article_params
    params.require(:article).permit(:title, :content)
  end
end

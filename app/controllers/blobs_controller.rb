# frozen_string_literal: true

class BlobsController < ApplicationController
  before_action :find_blog
  layout 'editor'

  def new
    @blob = Blob.new(blog: @blog)
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
    @edit = true
    @markdown_doc ||= CommonMarker.render_doc(@article.content || '')
  end

  def create
    Article.from(params[:content])
    @blog.create_draft_article(title: article_params[:title], content: frontmatter + "--- \n\n" + article_params[:content])
    redirect_to blog_path(@blog)
  end

  def update
    article = Article.from(params[:content])
    article.update
    redirect_to blog_article_path(@blog, article)
  end

  def destroy
    @blog.delete_article(id: params[:id], path: params[:path])
    redirect_to blog_path(@blog)
  end

  private

  def find_blog
    @blog = Current.user.blogs.friendly.find(params[:blog_id])
  end

  def article_params
    params.require(:article).permit(:title, :summary, :front_matter, :content)
  end
end

# frozen_string_literal: true

class PostsController < ApplicationController
  include Breadcrumbable

  before_action :find_publication
  before_action :find_post, only: %i[show update destroy edit]
  skip_verify_authorized only: :show

  private

  def find_post
    @post = @publication.posts.friendly.find(params[:permalink])
  end

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])
  end
end

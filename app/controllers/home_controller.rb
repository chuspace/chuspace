# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @posts = Post.all.limit(20)
    @publications = Publication.all.limit(5).except_personal
  end
end

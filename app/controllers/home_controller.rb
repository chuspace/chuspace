# frozen_string_literal: true

class HomeController < ApplicationController
  skip_verify_authorized

  def index
    @user = Current.user
    @posts = Post.includes(:topics, :author, :publication).published.newest.limit(20)
    @publications = Publication.all.limit(5).except_personal
  end
end

# frozen_string_literal: true

class HomeController < ApplicationController
  before_action :authenticate!
  skip_verify_authorized

  def index
    @user = Current.user
    @posts = Post.includes(:topics, :author, :publication).newest.limit(20)
    @publications = Publication.all.limit(5).except_personal
  end
end

# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @articles = Blog.all.flat_map(&:articles) if signed_in?
  end
end

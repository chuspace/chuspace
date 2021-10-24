# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @articles = Blog.all.flat_map(&:articles)
  end
end

# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @editions = Edition.all.limit(20)
  end
end

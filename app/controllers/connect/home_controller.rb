# frozen_string_literal: true

module Connect
  class HomeController < ApplicationController
    layout 'marketing', only: :index

    def index
    end
  end
end

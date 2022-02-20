# frozen_string_literal: true

module Connect
  class HomeController < ApplicationController
    layout 'marketing', only: :index
    skip_verify_authorized

    def index
    end
  end
end

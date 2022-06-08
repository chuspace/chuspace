# frozen_string_literal: true

module Connect
  class HomeController < ApplicationController
    skip_verify_authorized

    def index
    end
  end
end

# frozen_string_literal: true

module Connect
  class HomeController < BaseController
    def index
      authorize! @publication, to: :new?
    end
  end
end

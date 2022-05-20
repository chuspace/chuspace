# frozen_string_literal: true

module Users
  class PublicationsController < BaseController
    skip_verify_authorized

    def index
      add_breadcrumb(:Publications)
      @publications = @user.publications
    end
  end
end

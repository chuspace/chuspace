# frozen_string_literal: true

module Users
  class PublicationsController < BaseController
    layout false

    def index
      authorize! Current.user, to: :publications?
      @publications = authorized_scope(Publication.all, type: :relation, as: :write)
    end
  end
end

# frozen_string_literal: true

module Users
  class PublicationsController < BaseController
    def index
      authorize! Current.user, to: :show?
      add_breadcrumb(:Publications)
      @publications = authorized_scope(Publication.all, type: :relation, as: :member)
    end
  end
end

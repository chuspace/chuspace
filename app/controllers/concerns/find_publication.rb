# frozen_string_literal: true

module FindPublication
  extend ActiveSupport::Concern

  included do
    before_action :find_publication
  end

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])
    add_breadcrumb(@publication.permalink, publication_path(@publication))
  end
end

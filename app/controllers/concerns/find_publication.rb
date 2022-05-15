# frozen_string_literal: true

module FindPublication
  extend ActiveSupport::Concern

  included do
    before_action :find_publication
  end

  private

  def find_publication
    @publication = Publication.friendly.find(params[:publication_permalink])

    if params[:publication_permalink] != @publication.permalink
      redirect_to RedirectUrl.new(path: request.path, params: params).for(@publication), status: :moved_permanently
    end

    add_breadcrumb(@publication.permalink, publication_path(@publication))
  end
end

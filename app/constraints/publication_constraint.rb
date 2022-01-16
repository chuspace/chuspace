# frozen_string_literal: true

class PublicationConstraint
  def matches?(request)
    permalink = request.params[:permalink] || request.params[:publication_permalink]
    Publication.exists?(permalink: permalink) if permalink.present?
  end
end

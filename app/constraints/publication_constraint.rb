# frozen_string_literal: true

class PublicationConstraint
  def matches?(request)
    permalink = request.params[:publication_permalink] || request.params[:permalink]
    Publication.friendly.exists?(permalink)
  end
end

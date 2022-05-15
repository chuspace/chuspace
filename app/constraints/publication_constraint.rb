# frozen_string_literal: true

class PublicationConstraint
  def matches?(request)
    permalink = request.params[:publication_permalink] || request.params[:permalink]
    Publication.friendly.find(permalink)
  end
end

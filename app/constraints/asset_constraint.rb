# frozen_string_literal: true

class AssetConstraint
  def matches?(request)
    request.params[:publication_permalink] && request.params[:path].present?
  end
end

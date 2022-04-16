# frozen_string_literal: true

class AssetConstraint
  def matches?(request)
    request.params[:publication_permalink] && ImageValidator.valid?(name_or_path: request.params[:path])
  end
end
